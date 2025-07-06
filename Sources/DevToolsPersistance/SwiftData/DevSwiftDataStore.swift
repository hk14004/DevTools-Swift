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
    private let queue = DispatchQueue(
        label: "DevSwiftDataStoreQueue",
        qos: .default
    )
    
    // MARK: Init
    public init(container: ModelContainer, converter: Converter) {
        self.converter = converter
        self.context = queue.sync {
            ModelContext(container)
        }
    }
    
    // MARK: Read/Single
    public func getSingle(id: String) throws -> T? {
        try queue.sync {
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
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>] = []
    ) throws -> [T] {
        var result: [T] = []
        var caught: Error?
        
        queue.sync {
            do {
                result = try fetchListSync(
                    predicate: predicate,
                    sortDescriptors: sortDescriptors
                )
            } catch {
                caught = error
            }
        }
        
        if let error = caught { throw error }
        return result
    }
    
    public func getList(
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>] = []
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
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) throws -> DevPagedResult<T> {
        .init(pageNumber: 0, pageItems: [], hasNextPage: false)
    }
    
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) async throws -> DevPagedResult<T> {
        .init(pageNumber: 0, pageItems: [], hasNextPage: false)
    }
    
    // MARK: Read/Observe
    public func observeSingle(id: String) -> AnyPublisher<T?, Error> {
        .just(nil)
    }
    
    public func observeList(
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) -> AnyPublisher<[T], Error> {
        .just([])
    }
    
    // MARK: Write/Amend
    public func addOrUpdate(_ items: [T]) throws {
        
    }
    
    public func addOrUpdate(_ items: [T]) async throws {
        
    }
    
    // MARK: Write/Delete
    public func delete(_ itemIds: [String]) throws {
        
    }
    
    public func delete(_ itemIds: [String]) async throws {
        
    }
    
    // MARK: Write/Replace
    public func replace(with items: [T]) throws {
        
    }
    
    public func replace(with items: [T]) async throws {
        
    }
    
    // MARK: Write/Bulk
    public func bulkWrite(block: @escaping () throws -> Void) async throws {
        
    }
    
    public func bulkWrite(block: @escaping () throws -> Void) throws {
        
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
        predicate: Predicate<T.StoreType>,
        sortDescriptors: [SortDescriptor<T.StoreType>]
    ) throws -> [T] {
        let descriptor = FetchDescriptor<T.StoreType>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        let stored = try context.fetch(descriptor)
        return try stored.map { try converter.domainObject(from: $0) }
    }
}

extension DevSwiftDataStore: @unchecked Sendable {}
