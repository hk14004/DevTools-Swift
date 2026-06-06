//
//  DevSwiftDataStore.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation
import SwiftData
@preconcurrency import DevToolsCore
import Combine

public class DevSwiftDataStore<DTO, Converter>: DevSwiftDataInterface
where
    DTO: DevDBInterfaceDTO,
    DTO.StoreType: PersistentModel,
    DTO.StoreType.ID == String,
    Converter: DevModelConverter,
    Converter.DomainType == DTO,
    Converter.PersistedType == DTO.StoreType
{

    // MARK: Properties

    /// Read context — always accessed on the main thread.
    /// Never written to; only used for fetches and observation.
    internal let viewContext: ModelContext

    /// Write context — always accessed via writeQueue.
    /// Saves here commit to the persistent store; contextUpdatedPublisher
    /// then fires on the main thread so observers re-fetch from viewContext.
    internal let writeContext: ModelContext

    internal let converter: Converter
    internal let contextUpdatedPublisher = PassthroughSubject<Void, Never>()

    /// Serial queue that serialises all write operations and protects bulkWriteInProgress.
    private let writeQueue = DispatchQueue(
        label: "com.devtools.swiftdata.write",
        qos: .userInitiated
    )

    /// Only ever read or written from within writeQueue — serial queue provides safety.
    private var bulkWriteInProgress = false

    // MARK: Init

    /// Must be called on the main thread so that viewContext is created in the correct context.
    public init(container: ModelContainer, converter: Converter) {
        precondition(Thread.isMainThread, "DevSwiftDataStore must be initialised on the main thread")
        self.converter = converter
        self.viewContext = ModelContext(container)
        self.writeContext = writeQueue.sync { ModelContext(container) }
    }

    // MARK: Read / Single

    public func getSingle(id: String) throws -> DTO? {
        try performFetch(id: id)
    }

    public func getSingle(id: String) async throws -> DTO? {
        try await MainActor.run { try self.performFetch(id: id) }
    }

    // MARK: Read / List

    public func getList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) throws -> [DTO] {
        try performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    public func getList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) async throws -> [DTO] {
        try await MainActor.run {
            try self.performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }

    // MARK: Read / Page

    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) throws -> DevPagedResult<DTO> {
        try performFetchPage(pageOptions, predicate: predicate, sortDescriptors: sortDescriptors)
    }

    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) async throws -> DevPagedResult<DTO> {
        try await MainActor.run {
            try self.performFetchPage(pageOptions, predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }

    // MARK: Read / Observe

    public func observeSingle(id: String) -> AnyPublisher<DTO?, Error> {
        makeObservable { try self.getSingle(id: id) }
    }

    public func observeList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) -> AnyPublisher<[DTO], Error> {
        makeObservable {
            try self.getList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }

    // MARK: Write

    public func addOrUpdate(_ items: [DTO]) async throws {
        try await performWrite { try self.performAddOrUpdate(items) }
    }

    public func delete(_ itemIds: [String]) async throws {
        try await performWrite { try self.performDelete(itemIds) }
    }

    public func replace(with items: [DTO]) async throws {
        try await performWrite { try self.performReplace(items) }
    }

    // MARK: Write / Bulk

    /// Groups multiple writes into a single save, firing observers exactly once at the end.
    /// Call the store's normal async write methods inside the block.
    public func bulkWrite(block: @escaping () async throws -> Void) async throws {
        await withCheckedContinuation { cont in
            writeQueue.async {
                self.bulkWriteInProgress = true
                cont.resume()
            }
        }
        do {
            try await block()
        } catch {
            await withCheckedContinuation { cont in
                writeQueue.async {
                    if self.writeContext.hasChanges { self.writeContext.rollback() }
                    self.bulkWriteInProgress = false
                    cont.resume()
                }
            }
            throw error
        }
        try await withCheckedThrowingContinuation { cont in
            writeQueue.async {
                do {
                    try self.attemptSave()
                    self.bulkWriteInProgress = false
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
        await MainActor.run { self.contextUpdatedPublisher.send(()) }
    }

    // MARK: Private

    /// Runs an operation on writeQueue, saves if not in a bulk write, and notifies observers.
    private func performWrite(_ operation: @escaping () throws -> Void) async throws {
        let saved = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Bool, Error>) in
            writeQueue.async {
                do {
                    try operation()
                    if !self.bulkWriteInProgress {
                        try self.attemptSave()
                        cont.resume(returning: true)
                    } else {
                        cont.resume(returning: false)
                    }
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
        if saved {
            await MainActor.run { self.contextUpdatedPublisher.send(()) }
        }
    }

    private func makeObservable<Output>(_ fetch: @escaping () throws -> Output) -> AnyPublisher<Output, Error> {
        contextUpdatedPublisher
            .prepend(())
            .receive(on: DispatchQueue.main)
            .tryMap { _ in try fetch() }
            .eraseToAnyPublisher()
    }
}

// @unchecked Sendable is required because ModelContext is not Sendable.
// Thread safety is enforced by design:
//   - viewContext is only ever accessed on the main thread
//   - writeContext and bulkWriteInProgress are only ever accessed on writeQueue
extension DevSwiftDataStore: @unchecked Sendable {}

extension SortDescriptor where Compared: DevDBStoredObject, Compared.ID == String {
    public static var defaultSortDescriptors: [SortDescriptor<Compared>] {
        [.init(\.id, comparator: .localizedStandard)]
    }
}
