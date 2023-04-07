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

public class PersistentCoreDataStore<Domain: PersistableDomainModelProtocol> {
    
    // MARK: Properties
    
    public typealias T = Domain
    private let queue: DispatchQueue = .init(label: "DevTools.PersistentCoreDataStore.\(Domain.self)")
    private let context: NSManagedObjectContext
    private var bulkWriteInProgress = false
    
    // MARK: Init
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension PersistentCoreDataStore: PersistedLayerInterface where T.StoreType: NSManagedObject, T.StoreType.DomainModelType == T  {
    
    public func bulkWrite(operations: [() async -> Void]) async {
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
    
    public func addOrUpdate(_ items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.context.perform {
                    do {
                        for item in items {
                            let fetchRequest: NSFetchRequest<T.StoreType> = NSFetchRequest<T.StoreType>(entityName: "\(T.StoreType.self)")
                            fetchRequest.predicate = NSPredicate(format: "id == %@", item as! CVarArg)
                            
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
    
    public func getSingle(id: String) async -> Domain? {
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
    
    public func getList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> [Domain] {
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
                            .compactMap({ current in
                                try? current.toDomain(fields: T.StoreType.FieldType.getSetOfAllFields())
                            })
                        continuation.resume(returning: result)
                    } catch (let err) {
                        printError(err)
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
    
    public func getListPage(pageOptions: DevTools.PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> DevTools.PagedResult<Domain> {
        fatalError()
    }
    
    public func observeSingle(id: String) -> AnyPublisher<Domain?, Never> {
        fatalError()
    }
    
    public func observeList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> AnyPublisher<[Domain], Never> {
        fatalError()
    }
    
    public func delete(_ items: [Domain]) async {
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
                        continuation.resume()
                    } catch (let err) {
                        printError(err)
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    public func replace(with items: [Domain]) async {
        fatalError()
    }
}

extension NSPredicate: @unchecked Sendable { }
