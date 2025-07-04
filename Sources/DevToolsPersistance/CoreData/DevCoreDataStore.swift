//
//  DevCoreDataStore.swift
//
//
//  Created by Hardijs Ķirsis on 05/04/2023.
//

import Foundation
import CoreData
import DevToolsCore
import Combine

// TODO: Check read block by write
public class DevCoreDataStore<T, Converter>: DevPersistedLayerInterface
where
    T: DevDBInterfaceDTO,
    T.StoreType: NSManagedObject,
    Converter: DevModelConverter,
    Converter.DomainType == T,
    Converter.PersistedType == T.StoreType
{
    
    // MARK: Properties
    internal let context: NSManagedObjectContext
    internal let converter: Converter
    internal var bulkWriteInProgress = false
    
    // MARK: Init
    public init(context: NSManagedObjectContext, converter: Converter) {
        self.context = context
        self.converter = converter
    }
    
    // MARK: Read/Single
    public func getSingle(id: String) throws -> T? {
        try context.performAndWait {
            try performFetch(id: id)
        }
    }
    
    public func getSingle(id: String) async throws -> T? {
        try await context.perform {
            try self.performFetch(id: id)
        }
    }
    
    // MARK: Read/List
    public func getList(
        predicate: NSPredicate = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) throws -> [T] {
        try context.performAndWait {
            try performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }
    
    public func getList(
        predicate: NSPredicate = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) async throws -> [T] {
        try await context.perform {
            try self.performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }
    
    // MARK: Read/Page
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) throws -> DevPagedResult<T> {
        try context.performAndWait {
            try performFetchPage(
                pageOptions: pageOptions,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) async throws -> DevPagedResult<T> {
        try await context.perform {
            try self.performFetchPage(
                pageOptions: pageOptions,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    // MARK: Read/Observe
    public func observeSingle(id: String) -> AnyPublisher<T?, Error> {
        let fetchRequest = makeFetchRequest(
            predicate: makeIDPredicate(id),
            sortDescriptors: [NSSortDescriptor.makeStringIDSortDescriptor()]
        )
        return context.collectionPublisher(for: fetchRequest)
            .tryMap { storedItems in
                try storedItems
                    .first
                    .map { try self.converter.domainObject(from: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    public func observeList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> AnyPublisher<[T], Error> {
        let fetchRequest = makeFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        return context.collectionPublisher(for: fetchRequest)
            .tryMap { storedItems in
                try storedItems.map { item in
                    try self.converter.domainObject(from: item)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Write/Amend
    public func addOrUpdate(_ items: [T]) throws {
        try context.performAndWait {
            try performAddOrUpdate(items)
        }
    }
    
    public func addOrUpdate(_ items: [T]) async throws {
        try await context.perform {
            try self.performAddOrUpdate(items)
        }
    }
    
    // MARK: Write/Delete
    public func delete(_ itemIds: [String]) throws {
        try context.performAndWait {
            try performDelete(itemIds)
        }
    }
    
    public func delete(_ itemIds: [String]) async throws {
        try await context.perform {
            try self.performDelete(itemIds)
        }
    }
    
    // MARK: Write/Replace
    public func replace(with items: [T]) throws {
        try context.performAndWait {
            try performReplace(items)
        }
    }
    
    public func replace(with items: [T]) async throws {
        try await context.perform {
            try self.performReplace(items)
        }
    }
    
    // MARK: Write/Bulk
    public func bulkWrite(block: @escaping () throws -> Void) async throws {
        try await context.perform {
            try self.performBulkWriteOperaton(block: block)
        }
    }
    
    public func bulkWrite(block: @escaping () throws -> Void) throws {
        try context.performAndWait {
            try performBulkWriteOperaton(block: block)
        }
    }
}
