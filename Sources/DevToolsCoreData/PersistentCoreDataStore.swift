//
//  PersistentCoreDataStore.swift
//  
//
//  Created by Hardijs Ķirsis on 05/04/2023.
//

import Foundation
import CoreData
import DevTools
import Combine

public class PersistentCoreDataStore<Domain>: BasePersistedLayerInterface<Domain> where Domain: PersistableDomainModelProtocol,
                                                                                        Domain.StoreType: NSManagedObject,
                                                                                        Domain.StoreType.DomainModelType == Domain {
    
    // MARK: Properties
    
    public typealias T = Domain
    private let queue: DispatchQueue = .init(label: "DevTools.PersistentCoreDataStore.\(Domain.self)")
    private let context: NSManagedObjectContext
    private var bulkWriteInProgress = false
    
    // MARK: Init
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: Overriden
    
    public override func bulkWrite(operations: [() async -> Void]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    self.bulkWriteInProgress = true
                    Task {
                        for operation in operations {
                            await operation()
                        }
                        try! self.context.save()
                        self.bulkWriteInProgress = false
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    public override func addOrUpdate(_ items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        for item in items {
                            let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                            fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as! CVarArg)
                            
                            let result = try self.context.fetch(fetchRequest)
                            
                            if let stored = result.first {
                                stored.update(with: item, fields: Set(T.StoreType.FieldType.allCases))
                            } else {
                                let entity = T.StoreType(context: self.context)
                                entity.update(with: item, fields: Set(T.StoreType.FieldType.allCases))
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
                            fetchRequest.sortDescriptors = [.init(key: sortedByKeyPath, ascending: ascending)]
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
    
    public override func getListPage(pageOptions: DevTools.PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> DevTools.PagedResult<Domain> {
        fatalError()
    }
    
    public override func observeSingle(id: String) -> AnyPublisher<Domain?, Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return context.collectionPublisher(for: fetchRequest)
            .map({ storedArr in
                try! storedArr.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    public override func observeList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> AnyPublisher<[Domain], Never> {
        let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
        fetchRequest.predicate = predicate
        if !sortedByKeyPath.isEmpty {
            fetchRequest.sortDescriptors = [.init(key: sortedByKeyPath, ascending: ascending)]
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        }
        return context.collectionPublisher(for: fetchRequest)
            .map({ storedArr in
                storedArr.map { persisted in
                    try! persisted.toDomain(fields: Set(T.StoreType.FieldType.allCases))
                }
            })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    public override func delete(_ items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        let objectIDs = items.map { $0.id }
                        let predicate = NSPredicate(format: "self IN %@", objectIDs)
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
    
    public override func replace(with items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        let objectIDs = items.map { $0.id }
                        let predicate = NSPredicate(format: "self IN %@", objectIDs)
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
                                stored.update(with: item, fields: Set(T.StoreType.FieldType.allCases))
                            } else {
                                let entity = T.StoreType(context: self.context)
                                entity.update(with: item, fields: Set(T.StoreType.FieldType.allCases))
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
