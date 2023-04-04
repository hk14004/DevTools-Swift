//
//  File.swift
//  
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import DevTools
import Combine
import Realm
import RealmSwift

public class PersistentRealmStore<Domain: PersistableDomainModelProtocol> {
    public typealias T = Domain
    private var dbConfig: Realm.Configuration
    private let queue: DispatchQueue = .init(label: "DevTools.PersistentRealmStore.\(Domain.self)")
    
    public init(dbConfig: Realm.Configuration) {
        self.dbConfig = dbConfig
    }
    
}

extension PersistentRealmStore: PersistedLayerInterface where T.StoreType: RealmSwiftObject, T.StoreType.DomainModelType == T  {
    
    public func bulkWrite(operations: [() async -> Void]) async {
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
    
    public func addOrUpdate(_ items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let addedOrUpdatedEntities: [T.StoreType] = items.map {
                        let stored = T.StoreType()
                        stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
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
    
    public func replace(with items: [T]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let storedEntities = realm.objects(T.StoreType.self)
                    let newEntities: [T.StoreType] = items.map {
                        let stored = T.StoreType()
                        stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
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
    
    // MARK: Delete
    
    public func delete(_ items: [Domain]) async {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let storedEntities = items.compactMap {
                        realm.object(ofType: T.StoreType.self, forPrimaryKey: $0.id)
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
    
    // MARK: Read
    
    // TODO: Catch errors for read  transactions
    
    public func getSingle(id: String) async -> T? {
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
    
    public func getList(predicate: NSPredicate = NSPredicate(value: true), sortedByKeyPath: String = "", ascending: Bool = true) async -> [T] {
        await withCheckedContinuation { continuation in
            queue.async {
                autoreleasepool {
                    let realm = try! Realm(configuration: self.dbConfig)
                    let result = try? realm.objects(T.StoreType.self)
                        .filter(predicate)
                        .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
                        .compactMap {try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
                    continuation.resume(returning: result ?? [])
                }
            }
        }
    }
    
    public func getListPage(pageOptions: DevTools.PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> DevTools.PagedResult<Domain> {
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
                            .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
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
    
    public func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        let realm = try! Realm(configuration: dbConfig)
        return realm.objects(T.StoreType.self)
            .filter(NSPredicate(format: "id == %@", id))
            .collectionPublisher
            .subscribe(on: queue)
            .freeze()
            .map {try! $0.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func observeList(predicate: NSPredicate = NSPredicate(value: true), sortedByKeyPath: String = "", ascending: Bool = true) -> AnyPublisher<[T], Never> {
        let realm = try! Realm(configuration: dbConfig)
        return realm.objects(T.StoreType.self)
            .filter(predicate)
            .optionallySorted(byKeyPath: sortedByKeyPath, ascending: ascending)
            .collectionPublisher
            .subscribe(on: queue)
            .freeze()
            .map {try! $0.compactMap{try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}}
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension Results where Element: KeypathSortable {
    func optionallySorted(byKeyPath: String = "", ascending: Bool = true) -> Results<Element> {
        if byKeyPath.isEmpty {
            return self
        } else {
            return self.sorted(byKeyPath: byKeyPath, ascending: ascending)
        }
    }
}

extension Results where Element: PersistedModelProtocol {
    func mapToDomain(fetchOffset: Int, fetchLimit: Int, fields: Set<Element.FieldType>) -> [Element.DomainModelType] {
        let endIndex: Int = {
           let wantIndex = fetchOffset + fetchLimit - 1
            return [wantIndex, self.count-1].min()!
        }()
        var items: [Element.DomainModelType] = []
        guard fetchOffset <= endIndex else {
            return []
        }
        for index in fetchOffset...endIndex {
            guard let stored = self[safe: index] else {
                continue
            }
            guard let converted = try? stored.toDomain(fields: fields) else {
                continue
            }
            items.append(converted)
        }
        return items
    }
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension NSPredicate: @unchecked Sendable { }

