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
    private var realm: Realm
    
    public init(realm: Realm) {
        self.realm = realm
    }
}

extension PersistentRealmStore: PersistedLayerInterface where T.StoreType: RealmSwiftObject, T.StoreType.DomainModelType == T  {
    
    // MARK: Add, update
    
    public func addOrUpdate(_ items: [Domain], chain: [() -> ()] = []) {
        let addedOrUpdatedEntities: [T.StoreType] = items.map {
            let stored = T.StoreType()
            stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
            return stored
        }
        
        func writeOperation() {
            realm.add(addedOrUpdatedEntities, update: .modified)
            chain.forEach { chainWrite in
                chainWrite()
            }
        }
        
        if realm.isInWriteTransaction {
            writeOperation()
        } else {
            do {
                try realm.write {
                    writeOperation()
                }
            } catch(let error) {
                printError(error)
            }
        }
    }
    
    public func replace(with items: [T], chain: [() -> ()] = []) {
        let storedEntities = realm.objects(T.StoreType.self)
        let newEntities: [T.StoreType] = items.map {
            let stored = T.StoreType()
            stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
            return stored
        }
        
        func writeOperation() {
            realm.delete(storedEntities)
            realm.add(newEntities, update: .modified)
            chain.forEach { chainWrite in
                chainWrite()
            }
        }
        
        if realm.isInWriteTransaction {
            writeOperation()
        } else {
            do {
                try realm.write {
                    writeOperation()
                }
            } catch(let error) {
                printError(error)
            }
        }
    }
    
    // MARK: Delete
    
    public func delete(_ items: [Domain], chain: [() -> ()] = []) {
        let storedEntities = items.compactMap {
            realm.object(ofType: T.StoreType.self, forPrimaryKey: $0.id)
        }
        
        func writeTransaction() {
            realm.delete(storedEntities)
            chain.forEach { chainWrite in
                chainWrite()
            }
        }
        
        if realm.isInWriteTransaction {
            writeTransaction()
        } else {
            do {
                try realm.write {
                    writeTransaction()
                }
            } catch(let error) {
                printError(error)
            }
        }
    }
    
    // MARK: Read
    
    // TODO: Catch errors for read  transactions
    
    public func getSingle(id: String) -> T? {
        return try? realm.object(ofType: T.StoreType.self, forPrimaryKey: id)?.toDomain(fields: Set(T.StoreType.FieldType.allCases)) ?? nil
    }
    
    public func getList(predicate: NSPredicate = NSPredicate(value: true)) -> [T] {
        return try! realm.objects(T.StoreType.self).filter(predicate).compactMap {try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
    }
    
    public func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        return realm.objects(T.StoreType.self)
            .filter(NSPredicate(format: "id == %@", id))
            .collectionPublisher
            .receive(on: DispatchQueue.main)
            .freeze()
            .map {try! $0.first?.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    public func observeList(predicate: NSPredicate = NSPredicate(value: true)) -> AnyPublisher<[T], Never> {
        return realm.objects(T.StoreType.self)
            .filter(predicate)
            .collectionPublisher
            .receive(on: DispatchQueue.main)
            .freeze()
            .map {try! $0.compactMap{try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}}
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
