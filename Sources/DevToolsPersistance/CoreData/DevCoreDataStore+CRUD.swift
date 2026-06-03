//
//  DevCoreDataStore+CRUD.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation
import DevToolsCore
import CoreData

extension DevCoreDataStore {
    func performFetch(id: String) throws -> T? {
        try context
            .fetch(makeIDFetchRequest(id))
            .first
            .map { try converter.domainObject(from: $0) }
    }
    
    func performFetchList(
        predicate: NSPredicate?,
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
    
    func performFetchPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate? = .init(value: true),
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
    
    func performAddOrUpdate(_ items: [T]) throws {
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
    
    func performDelete(_ itemIds: [String]) throws {
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
    
    func performReplace(_ items: [T]) throws {
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
    
    func performBulkWriteOperation(block: () throws -> Void) throws {
        bulkWriteInProgress = true
        do {
            try block()
        } catch {
            context.rollback()
            bulkWriteInProgress = false
            throw error
        }
        try self.attemptSave()
        bulkWriteInProgress = false
    }
    
    func attemptSave() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func makeIDPredicate(_ id: String) -> NSPredicate {
        NSPredicate(format: "id == %@", id)
    }
    
    func makeIdInPredicate(_ ids: [String]) -> NSPredicate {
        NSPredicate(format: "id IN %@", ids)
    }
    
    func makeIDFetchRequest(_ id: String) -> NSFetchRequest<T.StoreType> {
        makeFetchRequest(predicate: makeIDPredicate(id))
    }
    
    func makeFetchRequest(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> NSFetchRequest<T.StoreType> {
        let request = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
}

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
