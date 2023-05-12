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

public class PersistentCoreDataStore<Domain>: BasePersistedLayerInterface<Domain> where Domain: PersistableDomainModelProtocol,
                                                                                        Domain.StoreType: NSManagedObject,
                                                                                        Domain.StoreType.DomainModelType == Domain {
    
    // MARK: Properties
    
    public typealias T = Domain
    private let queue: DispatchQueue
    private var context: NSManagedObjectContext!
    private let viewContext: NSManagedObjectContext
    private let storeContainer: NSPersistentContainer
    private var bulkWriteInProgress = false
    
    // MARK: Init
    
    public init(queue: DispatchQueue = DispatchQueue(label: "DevTools.PersistentCoreDataStore.\(Domain.self)"),
                storeContainer: NSPersistentContainer) {
        self.queue = queue
        self.storeContainer = storeContainer
        self.viewContext = storeContainer.viewContext
        super.init()
        self.queue.sync {
            self.context = storeContainer.newBackgroundContext()
            self.context.automaticallyMergesChangesFromParent = true
        }
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
                    try? self.context.save()
                    self.bulkWriteInProgress = false
                    continuation.resume()
                }
            }
        }
    }
    
    public override func addOrUpdate(_ items: [Domain],
                                     fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
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
            queue.async {
                self.context.perform {
                    do {
                        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                        
                        let result = try self.context.fetch(fetchRequest)
                            .first?.toDomain(fields: T.StoreType.FieldType.getSetOfAllFields())
                        continuation.resume(returning: result)
                    } catch (let err) {
                        printError(err)
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    public override func getList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> [Domain] {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                        fetchRequest.predicate = predicate
                        if !sortedByKeyPath.isEmpty {
                            fetchRequest.sortDescriptors = [
                                .init(key: sortedByKeyPath, ascending: ascending,
                                      selector: #selector(NSString.compare(_:)))
                            ]
                        }
                        
                        let result = try self.context.fetch(fetchRequest)
                        let r = result
                            .compactMap({ current in
                                try? current.toDomain(fields: T.StoreType.FieldType.getSetOfAllFields())
                            })
                        continuation.resume(returning: r)
                    } catch (let err) {
                        printError(err)
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
    
    public override func getListPage(pageOptions: DevToolsCore.PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> DevToolsCore.PagedResult<Domain> {
        fatalError()
    }
    
    public override func observeSingle(id: String) -> AnyPublisher<Domain?, Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true,
                             selector: #selector(NSString.compare(_:)))
        ]
        return viewContext.collectionPublisher(for: fetchRequest)
            .subscribe(on: queue)
            .map({ storedArr in
                try! storedArr.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))
            })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public override func observeList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> AnyPublisher<[Domain], Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = predicate
        if !sortedByKeyPath.isEmpty {
            fetchRequest.sortDescriptors = [
                .init(key: sortedByKeyPath, ascending: ascending,
                      selector: #selector(NSString.compare(_:)))
            ]
        } else {
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "id", ascending: true,
                                 selector: #selector(NSString.compare(_:)))
            ]
        }
        return viewContext.collectionPublisher(for: fetchRequest)
            .subscribe(on: queue)
            .map({ storedArr in
                storedArr.map { persisted in
                    try! persisted.toDomain(fields: Set(T.StoreType.FieldType.allCases))
                }
            })
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public override func delete(_ itemIds: [String]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
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
    
    public override func replace(with items: [Domain],
                                 fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        let predicate = NSPredicate(value: true)
                        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                        fetchRequest.predicate = predicate
                        
                        let objectsToDelete = try self.context.fetch(fetchRequest)
                        
                        for object in objectsToDelete {
                            self.context.delete(object)
                        }
                        
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
}

extension NSPredicate: @unchecked Sendable {}
