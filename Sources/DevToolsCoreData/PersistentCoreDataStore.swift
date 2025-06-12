//
//  PersistentCoreDataStore.swift
//
//
//  Created by Hardijs Ķirsis on 05/04/2023.
//

import Foundation
import CoreData
import DevToolsCore
import Combine

public class PersistentCoreDataStore<Domain>: BasePersistedLayerInterface<Domain>
where Domain: PersistableDomainModel,
      Domain.StoreType: NSManagedObject,
      Domain.StoreType.DomainModelType == Domain {
    
    // MARK: Properties
    public typealias T = Domain
    private let queue: DispatchQueue
    private let context: NSManagedObjectContext
    private var bulkWriteInProgress = false
    private var allStoredFields = T.StoreType.FieldType.getSetOfAllFields()
    
    // MARK: Init
    public init(
        queue: DispatchQueue = DispatchQueue(label: "DevTools.PersistentCoreDataStore.\(Domain.self)"),
        context: NSManagedObjectContext
    ) {
        self.queue = queue
        self.context = context
        super.init()
    }
    
    // MARK: Read
    // Single
    public override func getSingle(id: String) throws -> T? {
        try context.performAndWait {
            try self.context.fetch(makeIDFetchRequest(id))
                .first?
                .toDomain(fields: allStoredFields)
        }
    }
    
    public override func getSingle(id: String) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try self.context.fetch(self.makeIDFetchRequest(id))
                        .first?
                        .toDomain(fields: self.allStoredFields)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // List
    public override func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) throws -> [T] {
        try context.performAndWait {
            let fetchRequest = makeFetchRequest(
                predicate: predicate,
                sortDescriptors: sortDescriptors
            )
            
            let domainItems = try self.context.fetch(fetchRequest)
                .map { stored in
                    try stored.toDomain(fields: allStoredFields)
                }
            return domainItems
        }
    }
    
    public override func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = self.makeFetchRequest(
                        predicate: predicate,
                        sortDescriptors: sortDescriptors
                    )
                    
                    let domainItems = try self.context.fetch(fetchRequest)
                        .compactMap { stored in
                            try stored.toDomain(fields: self.allStoredFields)
                        }
                    continuation.resume(returning: domainItems)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Paging
    public override func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> PagedResult<T> {
        fatalError()
    }
    
    public override func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()])
    async -> PagedResult<Domain> {
        fatalError()
    }
    
    // MARK: Write
    // Amend
    public override func addOrUpdate(
        _ items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws {
        try context.performAndWait {
            let fetchRequest = makeFetchRequest(
                predicate: makeIdInPredicate(items.map { "\($0.id)" })
            )
            
            let existingDict = Dictionary<String, T.StoreType>(
                uniqueKeysWithValues: try context.fetch(fetchRequest)
                    .compactMap {
                        guard let id = $0.id as? String else { return nil }
                        return (id, $0)
                    }
            )
            
            for item in items {
                if let stored = existingDict["\(item.id)"] {
                    stored.update(with: item, fields: fields)
                } else {
                    T.StoreType(context: self.context).update(with: item, fields: fields)
                }
            }
            
            if !self.bulkWriteInProgress {
                try self.context.save()
            }
        }
    }
    
    
    public override func addOrUpdate(
        _ items: [Domain],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.context.perform {
                do {
                    let fetchRequest = self.makeFetchRequest(
                        predicate: self.makeIdInPredicate(items.map { "\($0.id)" })
                    )
                    
                    let existingDict = Dictionary<String, T.StoreType>(
                        uniqueKeysWithValues: try self.context.fetch(fetchRequest)
                            .compactMap {
                                guard let id = $0.id as? String else { return nil }
                                return (id, $0)
                            }
                    )
                    
                    for item in items {
                        if let stored = existingDict["\(item.id)"] {
                            stored.update(with: item, fields: fields)
                        } else {
                            T.StoreType(context: self.context).update(with: item, fields: fields)
                        }
                    }
                    
                    if !self.bulkWriteInProgress {
                        try self.context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Delete
    public override func delete(_ itemIds: [String]) throws {
        try context.performAndWait {
            let fetchRequest = makeFetchRequest(predicate: makeIdInPredicate(itemIds))
            let itemsToDelete = try context.fetch(fetchRequest)
            for item in itemsToDelete {
                context.delete(item)
            }
            if !self.bulkWriteInProgress {
                try self.context.save()
            }
        }
    }
    
    public override func delete(_ itemIds: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = self.makeFetchRequest(predicate: self.makeIdInPredicate(itemIds))
                    let itemsToDelete = try self.context.fetch(fetchRequest)
                    
                    for object in itemsToDelete {
                        self.context.delete(object)
                    }
                    if !self.bulkWriteInProgress {
                        try self.context.save()
                    }
                    continuation.resume()
                } catch  {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Replace
    public override func replace(
        with items: [Domain],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws  {
        try context.performAndWait {
            let fetchRequest = makeFetchRequest(predicate: NSPredicate(value: true))
            let itemsToDelete = try context.fetch(fetchRequest)
            
            for item in itemsToDelete {
                self.context.delete(item)
            }
            
            for item in items {
                let entity = T.StoreType(context: context)
                entity.update(with: item, fields: fields)
            }
            
            if !self.bulkWriteInProgress {
                try context.save()
            }
        }
    }
    
    public override func replace(
        with items: [Domain],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = self.makeFetchRequest(predicate: NSPredicate(value: true))
                    let itemsToDelete = try self.context.fetch(fetchRequest)
                    
                    for item in itemsToDelete {
                        self.context.delete(item)
                    }
                    
                    for item in items {
                        let entity = T.StoreType(context: self.context)
                        entity.update(with: item, fields: fields)
                    }
                    
                    if !self.bulkWriteInProgress {
                        try self.context.save()
                    }
                    continuation.resume()
                } catch  {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Observe

    public override func observeSingle(id: String) -> AnyPublisher<T?, Error> {
        let fetchRequest = makeFetchRequest(
            predicate: makeIDPredicate(id),
            sortDescriptors: [NSSortDescriptor.makeStringIDSortDescriptor()]
        )
        return context.collectionPublisher(for: fetchRequest)
            .tryMap { storedItems in
                try storedItems.first?.toDomain(fields: self.allStoredFields)
            }
            .eraseToAnyPublisher()
    }
    
    public override func observeList(
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
                    try item.toDomain(fields: self.allStoredFields)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Bulk
    public override func bulkWrite(operations: [() async -> Void]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.bulkWriteInProgress = true
                Task {
                    for operation in operations {
                        await operation()
                    }
                    self.queue.async {
                        self.context.performAndWait {
                            try? self.context.save()
                            self.bulkWriteInProgress = false
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Helpers
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
extension PersistentCoreDataStore: @unchecked Sendable where Domain: Sendable {}
