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

    // MARK: - Read (viewContext)

    func performFetch(id: String) throws -> T? {
        try viewContext
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
        return try viewContext
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
        request.fetchLimit  = pageOptions.pageSize + 1

        let allFetched = try viewContext.fetch(request)
            .map { try converter.domainObject(from: $0) }

        let pageItems = Array(allFetched.prefix(pageOptions.pageSize))
        let hasNext   = allFetched.count > pageOptions.pageSize

        return DevPagedResult(
            pageNumber: pageOptions.fetchPage,
            pageItems: pageItems,
            hasNextPage: hasNext
        )
    }

    // MARK: - Write (writeContext)
    // These are called from within writeContext.perform { } blocks — no save here.
    // Saving is handled by the public write methods in DevCoreDataStore.swift.

    func performAddOrUpdate(_ items: [T]) throws {
        let ids = items.map { "\($0.id)" }
        let fetchRequest = makeFetchRequest(predicate: makeIdInPredicate(ids))
        let existing = try writeContext.fetch(fetchRequest)
        let existingDict = Dictionary<String, T.StoreType>(
            uniqueKeysWithValues: existing.compactMap { obj in
                guard let id = obj.id as? String else { return nil }
                return (id, obj)
            }
        )
        for item in items {
            if let stored = existingDict["\(item.id)"] {
                try converter.updatePersistedObject(with: item, object: stored)
            } else {
                try converter.updatePersistedObject(with: item, object: T.StoreType(context: writeContext))
            }
        }
    }

    func performDelete(_ itemIds: [String]) throws {
        let fetchRequest = makeFetchRequest(predicate: makeIdInPredicate(itemIds))
        let itemsToDelete = try writeContext.fetch(fetchRequest)
        for object in itemsToDelete {
            writeContext.delete(object)
        }
    }

    func performReplace(_ items: [T]) throws {
        let fetchRequest = makeFetchRequest(predicate: .init(value: true))
        let allObjects = try writeContext.fetch(fetchRequest)
        for obj in allObjects {
            writeContext.delete(obj)
        }
        for item in items {
            let entity = T.StoreType(context: writeContext)
            try converter.updatePersistedObject(with: item, object: entity)
        }
    }

    // MARK: - Save

    func attemptSave() throws {
        guard writeContext.hasChanges else { return }
        do {
            try writeContext.save()
        } catch {
            writeContext.rollback()
            throw error
        }
    }

    // MARK: - Helpers

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

// MARK: - NSManagedObjectContext async helper

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
