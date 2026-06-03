//
//  DevSwiftDataStore+CRUD.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 07/07/2025.
//

import Foundation
import SwiftData
import DevToolsCore

extension DevSwiftDataStore {

    // MARK: - Read (viewContext — called on main thread)

    func performFetch(id: String) throws -> DTO? {
        let descriptor = FetchDescriptor<DTO.StoreType>(
            predicate: #Predicate { $0.id == id },
            sortBy: []
        )
        let stored = try viewContext.fetch(descriptor).first
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
        return try viewContext.fetch(descriptor)
            .map { try converter.domainObject(from: $0) }
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
        descriptor.fetchLimit  = pageOptions.pageSize + 1

        let fetched = try viewContext.fetch(descriptor)
        let items   = try fetched.map { try converter.domainObject(from: $0) }
        let page    = Array(items.prefix(pageOptions.pageSize))
        let hasNext = items.count > pageOptions.pageSize

        return DevPagedResult(pageNumber: pageOptions.fetchPage, pageItems: page, hasNextPage: hasNext)
    }

    // MARK: - Write (writeContext — called on writeQueue)
    // These do not save. Saving is managed by performWrite / bulkWrite in DevSwiftDataStore.swift.

    func performAddOrUpdate(_ items: [DTO]) throws {
        let ids    = items.map(\.id)
        let filter = #Predicate<DTO.StoreType> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<DTO.StoreType>(predicate: filter, sortBy: [])
        let existing   = try writeContext.fetch(descriptor)
        let byId       = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for item in items {
            if let stored = byId[item.id] {
                try converter.updatePersistedObject(with: item, object: stored)
            } else {
                writeContext.insert(try converter.persistableObject(from: item))
            }
        }
    }

    func performReplace(_ items: [DTO]) throws {
        try writeContext.fetch(FetchDescriptor<DTO.StoreType>())
            .forEach { writeContext.delete($0) }
        for item in items {
            writeContext.insert(try converter.persistableObject(from: item))
        }
    }

    func performDelete(_ itemIds: [String]) throws {
        let predicate  = #Predicate<DTO.StoreType> { itemIds.contains($0.id) }
        let descriptor = FetchDescriptor<DTO.StoreType>(predicate: predicate, sortBy: [])
        try writeContext.fetch(descriptor).forEach { writeContext.delete($0) }
    }

    // MARK: - Save (writeContext)

    func attemptSave() throws {
        guard writeContext.hasChanges else { return }
        do {
            try writeContext.save()
        } catch {
            writeContext.rollback()
            throw error
        }
    }
}
