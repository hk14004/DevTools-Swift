//
//  File.swift
//  
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import DevToolsCore
import Combine
import Realm
import RealmSwift

public class PersistentRealmStore<Domain>: BasePersistedLayerInterface<Domain> where Domain: PersistableDomainModel,
                                                                                   Domain.StoreType: RealmSwiftObject,
                                                                                   Domain.StoreType.DomainModelType == Domain {
    public typealias T = Domain
    private let dbConfig: Realm.Configuration
    private let queue: DispatchQueue = .init(label: "DevTools.PersistentRealmStore.\(Domain.self)")
    
    public init(dbConfig: Realm.Configuration) {
        self.dbConfig = dbConfig
        super.init()
    }
    
    // MARK: Override
    
    public override func bulkWrite(operations: [() async -> Void]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    realm.bulkWrite {
                        Task {
                            for operation in operations {
                                await operation()
                            }
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Add, update

    public override func addOrUpdate(_ items: [Domain],
                                     fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let addedOrUpdatedEntities: [T.StoreType] = items.map {
                        let stored = T.StoreType()
                        stored.update(with: $0, fields: fields)
                        return stored
                    }

                    func writeOperation() {
                        realm.add(addedOrUpdatedEntities, update: .modified)
                    }

                    realm.bulkWrite {
                        writeOperation()
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    public override func addOrUpdate(_ items: [Domain],
                                     fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) {
            queue.sync {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let addedOrUpdatedEntities: [T.StoreType] = items.map {
                        let stored = T.StoreType()
                        stored.update(with: $0, fields: fields)
                        return stored
                    }

                    func writeOperation() {
                        realm.add(addedOrUpdatedEntities, update: .modified)
                    }

                    realm.bulkWrite {
                        writeOperation()
                    }
                }
            }
        
    }

    public override func replace(with items: [T],
                                 fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let storedEntities = realm.objects(T.StoreType.self)
                    let newEntities: [T.StoreType] = items.map {
                        let stored = T.StoreType()
                        stored.update(with: $0, fields: fields)
                        return stored
                    }

                    func writeOperation() {
                        realm.delete(storedEntities)
                        realm.add(newEntities, update: .modified)
                    }

                    realm.bulkWrite {
                        writeOperation()
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    public override func replace(with items: [T],
                                 fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) {
        queue.sync {
            autoreleasepool {
                let realm = try! Realm(configuration: self.dbConfig)
                let storedEntities = realm.objects(T.StoreType.self)
                let newEntities: [T.StoreType] = items.map {
                    let stored = T.StoreType()
                    stored.update(with: $0, fields: fields)
                    return stored
                }
                
                func writeOperation() {
                    realm.delete(storedEntities)
                    realm.add(newEntities, update: .modified)
                }
                
                realm.bulkWrite {
                    writeOperation()
                }
            }
        }
    }

    // MARK: Delete

    public override func delete(_ itemIds: [String]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let storedEntities = itemIds.compactMap {
                        realm.object(ofType: T.StoreType.self, forPrimaryKey: $0)
                    }

                    func writeOperation() {
                        realm.delete(storedEntities)
                    }

                    realm.bulkWrite {
                        writeOperation()
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    public override func delete(_ itemIds: [String]) {
        queue.sync {
            autoreleasepool {
                let realm = try! Realm(configuration: self.dbConfig)
                let storedEntities = itemIds.compactMap {
                    realm.object(ofType: T.StoreType.self, forPrimaryKey: $0)
                }
                
                func writeOperation() {
                    realm.delete(storedEntities)
                }
                
                realm.bulkWrite {
                    writeOperation()
                }
            }
        }
    }

    // MARK: Read

    // TODO: Catch errors for read  transactions

    public override func getSingle(id: String) async -> T? {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let result = try? realm.object(ofType: T.StoreType.self, forPrimaryKey: id)?.toDomain(fields: Set(T.StoreType.FieldType.allCases)) ?? nil
                    continuation.resume(returning: result)
                }
            }
        }
    }

    public override func getSingle(id: String) -> T? {
        var result: T? = nil
        queue.sync {
            autoreleasepool {
                let realm = try! Realm(configuration: self.dbConfig)
                result = try? realm.object(ofType: T.StoreType.self, forPrimaryKey: id)?.toDomain(fields: Set(T.StoreType.FieldType.allCases)) ?? nil
            }
        }
        
        return result
    }
    
    public override func getList(predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]) async -> [T] {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let result = try? realm.objects(T.StoreType.self)
                        .filter(predicate)
//                        .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
                        .compactMap {try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
                    continuation.resume(returning: result ?? [])
                }
            }
        }
    }
    
    public override func getList(predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]) -> [T] {
        var result: [T] = []
        queue.sync {
            autoreleasepool {
                let realm = try! Realm(configuration: self.dbConfig)
                let fetch = try? realm.objects(T.StoreType.self)
                    .filter(predicate)
//                    .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
                    .compactMap {try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
                result = fetch ?? []
            }
        }
        return result
    }

    public override func getListPage(pageOptions: DevToolsCore.PagedRequestOptions, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) async -> DevToolsCore.PagedResult<Domain> {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    do {
                        let realm = try Realm(configuration: self.dbConfig)
                        let all = realm.objects(T.StoreType.self)
                        let total = all.count
                        let fetchOffset = (pageOptions.fetchPage - 1) * pageOptions.pageSize
                        let hasNextPage = fetchOffset + pageOptions.pageSize < total
                        let result = all
                            .filter(predicate)
//                            .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
                            .mapToDomain(fetchOffset: fetchOffset,
                                         fetchLimit: pageOptions.pageSize,
                                         fields: T.StoreType.FieldType.getSetOfAllFields())
                        let pageResult = PagedResult(pageNumber: pageOptions.fetchPage,
                                                 pageItems: result,
                                                 hasNextPage: hasNextPage)
                        continuation.resume(returning: pageResult)
                    } catch (let err) {
                        print(err)
                        continuation.resume(returning: .init(pageNumber: pageOptions.fetchPage, pageItems: [], hasNextPage: false))
                    }
                }
            }
        }
    }
    
    public override func getListPage(pageOptions: DevToolsCore.PagedRequestOptions, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> DevToolsCore.PagedResult<Domain> {
        var result: DevToolsCore.PagedResult<Domain>!
            queue.sync {
                autoreleasepool {
                    do {
                        let realm = try Realm(configuration: self.dbConfig)
                        let all = realm.objects(T.StoreType.self)
                        let total = all.count
                        let fetchOffset = (pageOptions.fetchPage - 1) * pageOptions.pageSize
                        let hasNextPage = fetchOffset + pageOptions.pageSize < total
                        let _result = all
                            .filter(predicate)
//                            .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
                            .mapToDomain(fetchOffset: fetchOffset,
                                         fetchLimit: pageOptions.pageSize,
                                         fields: T.StoreType.FieldType.getSetOfAllFields())
                        let result = PagedResult(pageNumber: pageOptions.fetchPage,
                                                 pageItems: _result,
                                                 hasNextPage: hasNextPage)
                    } catch (let err) {
                        printError(err)
                        result = .init(pageNumber: pageOptions.fetchPage, pageItems: [], hasNextPage: false)
                    }
                }
            }
        
        return result
    }

    public override func observeSingle(id: String) -> AnyPublisher<T?, Error> {
        let realm = try! Realm(configuration: dbConfig)
        return realm.objects(T.StoreType.self)
            .filter(NSPredicate(format: "id == %@", id))
            .collectionPublisher
            .subscribe(on: queue)
            .freeze()
            .map {try! $0.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public override func observeList(predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[T], Error> {
        let realm = try! Realm(configuration: dbConfig)
        return realm.objects(T.StoreType.self)
            .filter(predicate)
//            .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
            .collectionPublisher
            .subscribe(on: queue)
            .freeze()
            .map {try! $0.compactMap{try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NSPredicate: @unchecked Sendable { }
