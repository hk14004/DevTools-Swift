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

public class DevCoreDataStore<T, Converter>: DevCoreDataInterface
where
    T: DevDBInterfaceDTO,
    T.StoreType: NSManagedObject,
    Converter: DevModelConverter,
    Converter.DomainType == T,
    Converter.PersistedType == T.StoreType
{

    // MARK: Properties

    /// Read context — main queue. Used for all reads and observation.
    /// Automatically merges changes saved by writeContext.
    internal let viewContext: NSManagedObjectContext

    /// Write context — background queue. All mutations happen here.
    /// Saves here merge into viewContext automatically, triggering observers.
    internal let writeContext: NSManagedObjectContext

    internal let converter: Converter

    /// Only ever read or written from within writeContext.perform { } — serial queue provides safety.
    internal var bulkWriteInProgress = false

    // MARK: Init

    public init(container: NSPersistentContainer, converter: Converter) {
        self.converter = converter
        self.viewContext = container.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.writeContext = container.newBackgroundContext()
        self.writeContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: Read / Single

    public func getSingle(id: String) throws -> T? {
        try viewContext.performAndWait {
            try performFetch(id: id)
        }
    }

    public func getSingle(id: String) async throws -> T? {
        try await viewContext.perform {
            try self.performFetch(id: id)
        }
    }

    // MARK: Read / List

    public func getList(
        predicate: NSPredicate? = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) throws -> [T] {
        try viewContext.performAndWait {
            try performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }

    public func getList(
        predicate: NSPredicate? = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) async throws -> [T] {
        try await viewContext.perform {
            try self.performFetchList(predicate: predicate, sortDescriptors: sortDescriptors)
        }
    }

    // MARK: Read / Page

    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate? = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) throws -> DevPagedResult<T> {
        try viewContext.performAndWait {
            try performFetchPage(
                pageOptions: pageOptions,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }

    public func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate? = .init(value: true),
        sortDescriptors: [NSSortDescriptor] = [.makeStringIDSortDescriptor()]
    ) async throws -> DevPagedResult<T> {
        try await viewContext.perform {
            try self.performFetchPage(
                pageOptions: pageOptions,
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
        }
    }

    // MARK: Read / Observe

    public func observeSingle(id: String) -> AnyPublisher<T?, Error> {
        let fetchRequest = makeFetchRequest(
            predicate: makeIDPredicate(id),
            sortDescriptors: [NSSortDescriptor.makeStringIDSortDescriptor()]
        )
        return viewContext.collectionPublisher(for: fetchRequest)
            .tryMap { storedItems in
                try storedItems
                    .first
                    .map { try self.converter.domainObject(from: $0) }
            }
            .eraseToAnyPublisher()
    }

    public func observeList(
        predicate: NSPredicate? = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> AnyPublisher<[T], Error> {
        let fetchRequest = makeFetchRequest(
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        return viewContext.collectionPublisher(for: fetchRequest)
            .tryMap { storedItems in
                try storedItems.map { try self.converter.domainObject(from: $0) }
            }
            .eraseToAnyPublisher()
    }

    // MARK: Write / Amend

    public func addOrUpdate(_ items: [T]) async throws {
        try await writeContext.perform {
            try self.performAddOrUpdate(items)
            if !self.bulkWriteInProgress { try self.attemptSave() }
        }
    }

    // MARK: Write / Delete

    public func delete(_ itemIds: [String]) async throws {
        try await writeContext.perform {
            try self.performDelete(itemIds)
            if !self.bulkWriteInProgress { try self.attemptSave() }
        }
    }

    // MARK: Write / Replace

    public func replace(with items: [T]) async throws {
        try await writeContext.perform {
            try self.performReplace(items)
            if !self.bulkWriteInProgress { try self.attemptSave() }
        }
    }

    // MARK: Write / Bulk

    /// Runs all writes in the block as a single atomic save.
    /// Individual saves inside the block are suppressed; one save fires at the end.
    /// Observers on the view context receive a single update when the batch commits.
    public func bulkWrite(block: @escaping () async throws -> Void) async throws {
        await writeContext.perform { self.bulkWriteInProgress = true }
        do {
            try await block()
        } catch {
            await writeContext.perform {
                self.writeContext.rollback()
                self.bulkWriteInProgress = false
            }
            throw error
        }
        try await writeContext.perform {
            try self.attemptSave()
            self.bulkWriteInProgress = false
        }
    }
}
