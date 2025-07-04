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
    private let context: NSManagedObjectContext
    private var bulkWriteInProgress = false
    private let converter: Converter
    
    // MARK: Init
    public init(context: NSManagedObjectContext, converter: Converter) {
        self.context = context
        self.converter = converter
    }
    
    // MARK: Read
    // Single
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
    
    // List
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
    
    // Paging
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
    
    // MARK: – Async Paging
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
    
    // MARK: Write
    // Amend
    public func addOrUpdate(_ items: [T]) throws {
        try context.performAndWait {
            try performAddOrUpdate(items)
        }
    }
    
    // MARK: – Async Add/Update
    public func addOrUpdate(_ items: [T]) async throws {
        try await context.perform {
            try self.performAddOrUpdate(items)
        }
    }
    
    // Delete
    public func delete(_ itemIds: [String]) throws {
        try context.performAndWait {
            try performDelete(itemIds)
        }
    }
    
    // MARK: – Async Delete
    public func delete(_ itemIds: [String]) async throws {
        try await context.perform {
            try self.performDelete(itemIds)
        }
    }
    
    // Replace
    public func replace(with items: [T]) throws {
        try context.performAndWait {
            try performReplace(items)
        }
    }
    
    // MARK: – Async Replace
    public func replace(with items: [T]) async throws {
        try await context.perform {
            try self.performReplace(items)
        }
    }
    
    // MARK: Observe
    
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
    
    // MARK: Bulk
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
    
    private func performBulkWriteOperaton(block: @escaping () throws -> Void) throws {
        bulkWriteInProgress = true
        do {
            try block()
        } catch {
            context.rollback()
            bulkWriteInProgress = false
            throw DevPersistedLayerInterfaceError.underlying(error)
        }
        try self.attemptSave()
        bulkWriteInProgress = true
    }
    
    // MARK: Helpers
    private func attemptSave() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw DevPersistedLayerInterfaceError.underlying(error)
        }
    }
    
    private func makeIDPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
    
    private func makeIdInPredicate(_ ids: [String]) -> NSPredicate {
        NSPredicate(format: "id IN %@", ids)
    }
    
    private func makeIDFetchRequest(_ id: String) -> NSFetchRequest<T.StoreType> {
        makeFetchRequest(predicate: makeIDPredicate(id))
    }
    
    private func makeFetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchRequest<T.StoreType> {
        let request = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
}

extension NSPredicate: @unchecked @retroactive Sendable {}
extension NSSortDescriptor: @unchecked @retroactive Sendable {}
extension DevCoreDataStore: @unchecked Sendable where T: Sendable {}



extension NSManagedObjectContext {
    func perform<T>(_ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    continuation.resume(returning: try block())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension DevCoreDataStore {
    private func performFetch(id: String) throws -> T? {
        try context
            .fetch(makeIDFetchRequest(id))
            .first
            .map { try converter.domainObject(from: $0) }
    }
    
    private func performFetchList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [T] {
        let fetchRequest = makeFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        return try context
            .fetch(fetchRequest)
            .map { try converter.domainObject(from: $0) }
    }
    private func performFetchPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) throws -> DevPagedResult<T> {
        let request = makeFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        let zeroBasedPage = max(0, pageOptions.fetchPage - 1)
        request.fetchOffset = zeroBasedPage * pageOptions.pageSize
        request.fetchLimit  = pageOptions.pageSize + 1    // one extra to detect next page
        
        let allFetched = try context.fetch(request)
            .map { try converter.domainObject(from: $0) }
        
        let pageItems  = Array(allFetched.prefix(pageOptions.pageSize))
        let hasNext    = allFetched.count > pageOptions.pageSize
        
        return DevPagedResult(
            pageNumber: pageOptions.fetchPage,
            pageItems: pageItems,
            hasNextPage: hasNext
        )
    }
    
    private func performAddOrUpdate(_ items: [T]) throws {
        // 1. Fetch existing objects by ID
        let ids = items.map { "\($0.id)" }
        let fetchRequest = makeFetchRequest(
            predicate: makeIdInPredicate(ids)
        )
        let existing = try context.fetch(fetchRequest)
        let existingDict = Dictionary<String, T.StoreType>(
            uniqueKeysWithValues: existing.compactMap { obj in
                guard let id = obj.id as? String else { return nil }
                return (id, obj)
            }
        )
        
        // 2. Update or insert
        for item in items {
            if let stored = existingDict["\(item.id)"] {
                try converter.updatePersistedObject(with: item, object: stored)
            } else {
                try converter.updatePersistedObject(with: item, object: T.StoreType(context: context))
            }
        }
        
        // 3. Save if not in a bulk batch
        if !bulkWriteInProgress {
            try attemptSave()
        }
    }
    
    private func performDelete(_ itemIds: [String]) throws {
        let fetchRequest = makeFetchRequest(
            predicate: makeIdInPredicate(itemIds)
        )
        let itemsToDelete = try context.fetch(fetchRequest)
        for object in itemsToDelete {
            context.delete(object)
        }
        if !bulkWriteInProgress {
            try attemptSave()
        }
    }
    
    private func performReplace(_ items: [T]) throws {
        // 1. Delete everything
        let fetchRequest = makeFetchRequest(predicate: .init(value: true))
        let allObjects = try context.fetch(fetchRequest)
        for obj in allObjects {
            context.delete(obj)
        }
        
        // 2. Insert new items
        for item in items {
            let entity = T.StoreType(context: context)
            try converter.updatePersistedObject(with: item, object: entity)
        }
        
        // 3. Save if not in bulk
        if !bulkWriteInProgress {
            try attemptSave()
        }
    }
}
