//
//  DevSwiftDataStore+CRUD.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 07/07/2025.
//

import Foundation
import SwiftData
import DevToolsCore
import Combine

extension DevSwiftDataStore {
    func performFetch(id: String) throws -> DTO? {
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: #Predicate { $0.id == id },
            sortBy: []
        )
        let stored = try context.fetch(descriptor).first
        return try stored.map { try converter.domainObject(from: $0) }
    }
    
    func performFetchList(
        predicate: Predicate<DTO.StoreType>?,
        sortDescriptors: [SortDescriptor<DTO.StoreType>]
    ) throws -> [DTO] {
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        let stored = try context.fetch(descriptor)
        return try stored.map { try converter.domainObject(from: $0) }
    }
    
    func performAddOrUpdate(_ items: [DTO]) throws {
        let ids = items.map(\.id)
        let filter = #Predicate<DTO.StoreType> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: filter,
            sortBy: []
        )
        let existing = try context.fetch(descriptor)
        let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

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

        if !bulkWriteInProgress {
            try attemptSave()
        }
    }

    func performReplace(_ items: [DTO]) throws {
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: nil,
            sortBy: []
        )
        let existing = try context.fetch(descriptor)
        existing.forEach { context.delete($0) }

        for item in items {
            let newObj = try converter.persistableObject(from: item)
            context.insert(newObj)
        }

        if !bulkWriteInProgress {
            try attemptSave()
        }
    }

    func performDelete(_ itemIds: [String]) throws {
        let predicate = #Predicate<DTO.StoreType> { itemIds.contains($0.id) }
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: predicate,
            sortBy: []
        )

        let toDelete = try context.fetch(descriptor)
        toDelete.forEach { context.delete($0) }

        if !bulkWriteInProgress {
            try attemptSave()
        }
    }
    
    func performFetchPage(
        _ pageOptions: DevPagedRequestOptions,
        predicate: Predicate<DTO.StoreType>?,
        sortDescriptors: [SortDescriptor<DTO.StoreType>]
    ) throws -> DevPagedResult<DTO> {
        var descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        
        let zeroBasedPage = max(0, pageOptions.fetchPage - 1)
        descriptor.fetchOffset = zeroBasedPage * pageOptions.pageSize
        descriptor.fetchLimit  = pageOptions.pageSize + 1  // fetch one extra to detect next
        
        let fetched = try context.fetch(descriptor)
        let domainItems = try fetched.map { try converter.domainObject(from: $0) }
        
        let items = Array(domainItems.prefix(pageOptions.pageSize))
        let hasNext = domainItems.count > pageOptions.pageSize
        return DevPagedResult(
            pageNumber: pageOptions.fetchPage,
            pageItems: items,
            hasNextPage: hasNext
        )
    }
    
    func performBulkWriteOperation(_ block: () throws -> Void) throws {  // non-escaping: block runs synchronously
        bulkWriteInProgress = true
        do {
            try block()
            try attemptSave()
        } catch {
            if context.hasChanges {
                context.rollback()
            }
            bulkWriteInProgress = false
            throw error
        }
        bulkWriteInProgress = false
    }
    
    func attemptSave() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
            contextUpdatedPublisher.send(())
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func syncOperation<R>(_ block: () throws -> R) throws -> R {
        if isMainQueue {
            try block()
        } else {
            try queue.sync { try block() }
        }
    }
    
    func makeObservable<Output>(
        _ fetch: @escaping () throws -> Output
    ) -> AnyPublisher<Output, Error> {
        contextUpdatedPublisher
            .prepend(())
            .tryMap { _ in try fetch() }
            .eraseToAnyPublisher()
    }
}
