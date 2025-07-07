//
//  DevSwiftDataStore.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation
import SwiftData
import DevToolsCore
import Combine

// TODO: Check read block by write
public class DevSwiftDataStore<T, Converter>: DevSwiftDataInterface
where
T: DevDBInterfaceDTO,
T.StoreType: PersistentModel,
T.StoreType.ID == String,
Converter: DevModelConverter,
Converter.DomainType == T,
Converter.PersistedType == T.StoreType
{
    
    // MARK: Properties
    internal let context: ModelContext
    internal let converter: Converter
    internal var bulkWriteInProgress = false
    // Async barrier?
    private let queue: DispatchQueue
    private let isMainQueue: Bool
    private let contextUpdatedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: Init
    public init(container: ModelContainer, converter: Converter, queue: DispatchQueue) {
        self.converter = converter
        self.queue = queue
        self.isMainQueue = queue == .main
        if isMainQueue {
            // we’re already on (or will run on) the main thread
            self.context = ModelContext(container)
        } else {
            // true background queue: confine context creation to it
            self.context = queue.sync { ModelContext(container) }
        }
    }
    
    private func performSync<R>(_ block: () throws -> R) throws -> R {
        if isMainQueue {
            try block()
        } else {
            try queue.sync { try block() }
        }
    }
    
    // MARK: Read/Single
    public func getSingle(id: String) throws -> T? {
        try performSync {
            try performFetch(id: id)
        }
    }
    
    // MARK: – Read / Single (async)
    public func getSingle(id: String) async throws -> T? {
        try await withCheckedThrowingContinuation { cont in
            queue.async {
                do {
                    let dto = try self.performFetch(id: id)
                    cont.resume(returning: dto)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Read/List
    public func getList(
        predicate: Predicate<T.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<T.StoreType>] = [SortDescriptor(\.id, comparator: .localizedStandard)]
    ) throws -> [T] {
        try performSync {
            try fetchListSync(
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    public func getList(
        predicate: Predicate<T.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<T.StoreType>] = [SortDescriptor(\.id, comparator: .localizedStandard)]
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { cont in
            queue.async { [weak self] in
                guard let self = self else {
                    cont.resume(returning: [])  // or cont.resume(throwing: SomeError.storeDeallocated)
                    return
                }
                do {
                    let items = try self.fetchListSync(
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
        predicate: Predicate<T.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<T.StoreType>] = [SortDescriptor(\.id, comparator: .localizedStandard)]
    ) throws -> DevPagedResult<T> {
        try performSync {
            try performFetchPage(pageOptions, predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }
    
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<T.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<T.StoreType>] = [SortDescriptor(\.id, comparator: .localizedStandard)]
    ) async throws -> DevPagedResult<T> {
        try await withCheckedThrowingContinuation { cont in
                queue.async { [weak self] in
                    guard let self = self else {
                        cont.resume(returning: DevPagedResult(pageNumber: pageOptions.fetchPage,
                                                              pageItems: [],
                                                              hasNextPage: false))
                        return
                    }
                    do {
                        let result = try self.performFetchPage(pageOptions,
                                                               predicate: predicate,
                                                               sortDescriptors: sortDescriptors)
                        cont.resume(returning: result)
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
            }
    }
    
    // MARK: Read/Observe
    public func observeSingle(id: String) -> AnyPublisher<T?, Error> {
           // 1) Initial fetch wrapped in a Deferred Future
           let initial = Deferred {
               Future<T?, Error> { [weak self] promise in
                   guard let self = self else {
                       promise(.success(nil))
                       return
                   }
                   do {
                       let dto = try self.getSingle(id: id)
                       promise(.success(dto))
                   } catch {
                       promise(.failure(error))
                   }
               }
           }
           .eraseToAnyPublisher()

           // 2) Subsequent fetches upon context updates
           let updates = contextUpdatedPublisher
               .flatMap { [weak self] _ -> AnyPublisher<T?, Error> in
                   Deferred {
                       Future<T?, Error> { promise in
                           guard let self = self else {
                               promise(.success(nil))
                               return
                           }
                           do {
                               let dto = try self.getSingle(id: id)
                               promise(.success(dto))
                           } catch {
                               promise(.failure(error))
                           }
                       }
                   }
                   .eraseToAnyPublisher()
               }
               .eraseToAnyPublisher()

           // 3) Return initial value followed by updates
           return initial
               .append(updates)
               .eraseToAnyPublisher()
       }
    
    public func observeList(
        predicate: Predicate<T.StoreType>? = nil,
        sortDescriptors: [SortDescriptor<T.StoreType>] = [SortDescriptor(\.id, comparator: .localizedStandard)]
    ) -> AnyPublisher<[T], Error> {
        // 1) Initial fetch
        let initial = Deferred {
            Future<[T], Error> { [weak self] promise in
                guard let self = self else {
                    promise(.success([]))
                    return
                }
                do {
                    let list = try self.getList(
                        predicate: predicate,
                        sortDescriptors: sortDescriptors
                    )
                    promise(.success(list))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()

        // 2) Updates on each save/mutation
        let updates = contextUpdatedPublisher
            .flatMap { [weak self] _ -> AnyPublisher<[T], Error> in
                Deferred {
                    Future<[T], Error> { promise in
                        guard let self = self else {
                            promise(.success([]))
                            return
                        }
                        do {
                            let list = try self.getList(
                                predicate: predicate,
                                sortDescriptors: sortDescriptors
                            )
                            promise(.success(list))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        // 3) Concatenate initial result with live updates
        return initial
            .append(updates)
            .eraseToAnyPublisher()
    }

    
    // MARK: Write/Amend
    public func addOrUpdate(_ items: [T]) throws {
        try performSync {
            try performAddOrUpdate(items)
        }
    }
    
    public func addOrUpdate(_ items: [T]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
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
        try performSync {
            try performDelete(itemIds)
        }
    }
    
    public func delete(_ itemIds: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
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
    public func replace(with items: [T]) throws {
        try performSync {
            try performReplace(items)
        }
    }
    
    public func replace(with items: [T]) async throws {
        try await withCheckedThrowingContinuation { cont in
            queue.async { [weak self] in
                guard let self = self else {
                    cont.resume()
                    return
                }
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
    public func bulkWrite(block: @escaping () throws -> Void) throws {
        try performSync {
            try performBulkWriteOperation(block)
        }
    }
    
    public func bulkWrite(block: @escaping () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
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


extension DevSwiftDataStore {
    private func performFetch(id: String) throws -> T? {
        let descriptor = FetchDescriptor<T.StoreType>(
            predicate: #Predicate { $0.id == id },
            sortBy: []
        )
        let stored = try context.fetch(descriptor).first
        return try stored.map { try converter.domainObject(from: $0) }
    }
    
    private func fetchListSync(
        predicate: Predicate<T.StoreType>?,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) throws -> [T] {
        let descriptor = FetchDescriptor<T.StoreType>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        let stored = try context.fetch(descriptor)
        return try stored.map { try converter.domainObject(from: $0) }
    }
    
    private func performAddOrUpdate(_ items: [T]) throws {
        // 1. Fetch any existing persisted models with matching IDs
        let ids = items.map(\.id)
        let filter = #Predicate<T.StoreType> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<T.StoreType>(
            predicate: filter,
            sortBy: []
        )
        let existing = try context.fetch(descriptor)
        let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        
        // 2. For each domain item, update or insert
        for item in items {
            if let stored = existingById[item.id] {
                // update existing
                try converter.updatePersistedObject(with: item, object: stored)
            } else {
                // create new
                let newObj = try converter.persistableObject(from: item)
                context.insert(newObj)
            }
        }
        
        // 3. Persist changes
        try attemptSave()
    }
    
    private func performReplace(_ items: [T]) throws {
            // 1) Delete all existing
            let descriptor = FetchDescriptor<T.StoreType>(
                predicate: nil,
                sortBy: []
            )
            let existing = try context.fetch(descriptor)
            existing.forEach { context.delete($0) }

            // 2) Insert new items
            for item in items {
                let newObj = try converter.persistableObject(from: item)
                context.insert(newObj)
            }

            // 3) Save
        try attemptSave()
        }
    
    private func performDelete(_ itemIds: [String]) throws {
        // 1) Build a SwiftData predicate matching any of the IDs
        let predicate = #Predicate<T.StoreType> { itemIds.contains($0.id) }
        let descriptor = FetchDescriptor<T.StoreType>(
            predicate: predicate,
            sortBy: []
        )

        // 2) Fetch & delete
        let toDelete = try context.fetch(descriptor)
        toDelete.forEach { context.delete($0) }

        // 3) Persist
        try attemptSave()
    }
    
    private func performFetchPage(
        _ pageOptions: DevPagedRequestOptions,
        predicate: Predicate<T.StoreType>?,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) throws -> DevPagedResult<T> {
        // 1) Build descriptor
        var descriptor = FetchDescriptor<T.StoreType>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        
        // 2) Configure paging
        let zeroBasedPage = max(0, pageOptions.fetchPage - 1)
        descriptor.fetchOffset = zeroBasedPage * pageOptions.pageSize
        descriptor.fetchLimit  = pageOptions.pageSize + 1  // fetch one extra to detect next
        
        // 3) Execute & map
        let fetched = try context.fetch(descriptor)
        let domainItems = try fetched.map { try converter.domainObject(from: $0) }
        
        // 4) Build result
        let items     = Array(domainItems.prefix(pageOptions.pageSize))
        let hasNext   = domainItems.count > pageOptions.pageSize
        return DevPagedResult(
            pageNumber: pageOptions.fetchPage,
            pageItems: items,
            hasNextPage: hasNext
        )
    }
    
    private func performBulkWriteOperation(_ block: () throws -> Void) throws {
        // Begin bulk write
        bulkWriteInProgress = true
        do {
            // Execute user’s block (inserts, deletes, updates, etc.)
            try block()
            // Persist all changes
            try attemptSave()
        } catch {
            // On failure, roll back uncommitted changes
            if context.hasChanges {
                context.rollback()
            }
            bulkWriteInProgress = false
            throw error
        }
        // End bulk write
        bulkWriteInProgress = false
    }
    
    func attemptSave() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
            contextUpdatedPublisher.send(())
        } catch {
            context.rollback()
            throw DevPersistedLayerInterfaceError.underlying(error)
        }
    }
}

extension DevSwiftDataStore: @unchecked Sendable {}
