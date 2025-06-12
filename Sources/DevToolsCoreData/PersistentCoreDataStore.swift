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

// TODO: Handle all throws

public class PersistentCoreDataStore<Domain>: BasePersistedLayerInterface<Domain>
where Domain: PersistableDomainModel,
      Domain.StoreType: NSManagedObject,
      Domain.StoreType.DomainModelType == Domain {
    
    // MARK: Properties
    public typealias T = Domain
    private let queue: DispatchQueue
    private lazy var context: NSManagedObjectContext = {
        let context = storeContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    private let viewContext: NSManagedObjectContext
    private let storeContainer: NSPersistentContainer
    private var bulkWriteInProgress = false
    
    // MARK: Init
    public init(
        queue: DispatchQueue = DispatchQueue(label: "DevTools.PersistentCoreDataStore.\(Domain.self)"),
        storeContainer: NSPersistentContainer
    ) {
        self.queue = queue
        self.storeContainer = storeContainer
        self.viewContext = storeContainer.viewContext
        super.init()
        configureNotifications()
    }
    
    // MARK: Overriden
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
    
    public override func addOrUpdate(
        _ items: [Domain],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.performAndWait {
                    do {
                        for item in items {
                            let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                            fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as! CVarArg)
                            
                            let result = try self.context.fetch(fetchRequest)
                            
                            if let stored = result.first {
                                stored.update(with: item, fields: fields)
                            } else {
                                let entity = T.StoreType(context: self.context)
                                entity.update(with: item, fields: fields)
                            }
                        }
                        
                        if !self.bulkWriteInProgress {
                            try self.context.save()
                        }
                        continuation.resume()
                    } catch (let err) {
                        printError(err)
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    public override func getSingle(id: String) async -> Domain? {
        await withCheckedContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", id)

                    let result = try self.context.fetch(fetchRequest)
                        .first?
                        .toDomain(fields: T.StoreType.FieldType.getSetOfAllFields())
                    
                    continuation.resume(returning: result)
                } catch {
                    printError(error)
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    
    
    public override func getList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async -> [Domain] {
        await withCheckedContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                    fetchRequest.predicate = predicate
                    fetchRequest.sortDescriptors = sortDescriptors

                    let storeObjects = try self.context.fetch(fetchRequest)
                    let domainObjects = storeObjects.compactMap {
                        try? $0.toDomain(fields: T.StoreType.FieldType.getSetOfAllFields())
                    }
                    continuation.resume(returning: domainObjects)
                } catch {
                    printError(error)
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    public override func getListPage(
        pageOptions: DevToolsCore.PagedRequestOptions,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()])
    async -> DevToolsCore.PagedResult<Domain> {
        fatalError()
    }
    
    public override func observeSingle(id: String) -> AnyPublisher<Domain?, Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.sortDescriptors = [NSSortDescriptor.makeStringIDSortDescriptor()]
        return context.collectionPublisher(for: fetchRequest)
            .map { storedItem in
                try? storedItem.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    public override func observeList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> AnyPublisher<[Domain], Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        return context.collectionPublisher(for: fetchRequest)
            .map { storedItems in
                storedItems.compactMap { persisted in
                    try? persisted.toDomain(fields: Set(T.StoreType.FieldType.allCases))
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    public override func delete(_ itemIds: [String]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.performAndWait {
                    do {
                        let predicate = NSPredicate(format: "id IN %@", itemIds)
                        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                        fetchRequest.predicate = predicate
                        
                        let objectsToDelete = try self.context.fetch(fetchRequest)
                        
                        for object in objectsToDelete {
                            self.context.delete(object)
                        }
                        if !self.bulkWriteInProgress {
                            try self.context.save()
                        }
                        continuation.resume()
                    } catch (let err) {
                        printError(err)
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    public override func replace(
        with items: [Domain],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.performAndWait {
                    do {
                        let predicate = NSPredicate(value: true)
                        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                        fetchRequest.predicate = predicate
                        
                        let objectsToDelete = try self.context.fetch(fetchRequest)
                        
                        for object in objectsToDelete {
                            self.context.delete(object)
                        }
                        
                        for item in items {
                            let entity = T.StoreType(context: self.context)
                            entity.update(with: item, fields: fields)
                        }
                        
                        if !self.bulkWriteInProgress {
                            try self.context.save()
                        }
                        continuation.resume()
                    } catch (let err) {
                        printError(err)
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    // MARK: Notifications
    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidChange(notification:)),
            name: .NSManagedObjectContextDidSave, object: context
        )
    }
    
    @objc func contextDidChange(notification: Notification) {
        viewContext.mergeChanges(fromContextDidSave: notification)
    }
}

extension NSPredicate: @unchecked @retroactive Sendable {}
extension NSSortDescriptor: @unchecked @retroactive Sendable {}
extension PersistentCoreDataStore: @unchecked Sendable where Domain: Sendable {}
