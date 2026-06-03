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

// TODO: Implement async barrier?
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
    internal let context: ModelContext
    internal let converter: Converter
    internal var bulkWriteInProgress = false
    internal let queue: DispatchQueue
    internal let isMainQueue: Bool
    internal let contextUpdatedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: LifeCycle
    public init(
        container: ModelContainer,
        converter: Converter,
        queue: DispatchQueue
    ) {
        self.converter = converter
        self.queue = queue
        self.isMainQueue = queue == .main
        if isMainQueue {
            self.context = ModelContext(container)
        } else {
            self.context = queue.sync { ModelContext(container) }
        }
    }
    
    // MARK: Read/Single
    public func getSingle(id: String) throws -> DTO? {
        try syncOperation {
            try performFetch(id: id)
        }
    }
    
    // MARK: – Read / Single (async)
    public func getSingle(id: String) async throws -> DTO? {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    cont.resume(returning: try self.performFetch(id: id))
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Read/List
    public func getList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) throws -> [DTO] {
        try syncOperation {
            try performFetchList(
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    public func getList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) async throws -> [DTO] {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let items = try self.performFetchList(
                        predicate: predicate,
                        sortDescriptors: sortDescriptors
                    )
                    cont.resume(returning: items)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Read/Page
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) throws -> DevPagedResult<DTO> {
        try syncOperation {
            try performFetchPage(
                pageOptions,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) async throws -> DevPagedResult<DTO> {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let result = try self.performFetchPage(
                        pageOptions,
                        predicate: predicate,
                        sortDescriptors: sortDescriptors
                    )
                    cont.resume(returning: result)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Read/Observe
    public func observeSingle(id: String) -> AnyPublisher<DTO?, Error> {
        makeObservable { try self.getSingle(id: id) }
    }
    
    public func observeList(
        predicate: Predicate<DTO.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<DTO.StoreType>] = SortDescriptor<DTO.StoreType>.defaultSortDescriptors
    ) -> AnyPublisher<[DTO], Error> {
        makeObservable {
            try self.getList(
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    // MARK: Write/Amend
    public func addOrUpdate(_ items: [DTO]) throws {
        try syncOperation {
            try performAddOrUpdate(items)
        }
    }
    
    public func addOrUpdate(_ items: [DTO]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    try self.performAddOrUpdate(items)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Write/Delete
    public func delete(_ itemIds: [String]) throws {
        try syncOperation {
            try performDelete(itemIds)
        }
    }
    
    public func delete(_ itemIds: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    try self.performDelete(itemIds)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Write/Replace
    public func replace(with items: [DTO]) throws {
        try syncOperation {
            try performReplace(items)
        }
    }
    
    public func replace(with items: [DTO]) async throws {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    try self.performReplace(items)
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Write/Bulk
    public func bulkWrite(block: () throws -> Void) throws {
        try syncOperation {
            try performBulkWriteOperation(block)
        }
    }
    
    public func bulkWrite(block: @escaping () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    try self.performBulkWriteOperation(block)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension DevSwiftDataStore: @unchecked Sendable {}

extension SortDescriptor where Compared: DevDBStoredObject, Compared.ID == String {
    public static var defaultSortDescriptors: [SortDescriptor<Compared>] {
        [ .init(\.id, comparator: .localizedStandard) ]
    }
}
