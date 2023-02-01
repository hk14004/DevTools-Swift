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

    public func addOrUpdate(_ items: [T]) -> Bool {
//        let realm = try! Realm()
        let entities: [RealmSwiftObject] = items.map {
            let stored = T.StoreType()
            stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
            return stored
        }
        do {
            try realm.write {
                realm.add(entities, update: .modified)
            }
            return true
        } catch(let err) {
            //Log.s("Could not write to realm: \(err.localizedDescription)")
            return false
        }
    }

    public func replace(with items: [T]) -> Bool {
//        let realm = try! Realm()
        let stored = realm.objects(T.StoreType.self)
        let new: [RealmSwiftObject] = items.map {
            let stored = T.StoreType()
            stored.update(with: $0, fields: Set(T.StoreType.FieldType.allCases))
            return stored
        }
        do {
            try realm.write {
                realm.delete(stored)
                realm.add(new, update: .modified)
            }
            return true
        } catch(let err) {
            //Log.s("Could not write to realm: \(err.localizedDescription)")
            return false
        }
    }

    // MARK: Delete

    public func delete(_ items: [T]) -> Bool {
//        let realm = try! Realm()
        let storedItems = items.compactMap {
            realm.object(ofType: T.StoreType.self, forPrimaryKey: $0.id)
        }
        do {
            try realm.write {
                realm.delete(storedItems)
            }
            return true
        } catch(let err) {
            //Log.s("Could not write to realm: \(err.localizedDescription)")
            return false
        }
    }

    // MARK: Read

    // TODO: Catch
    
    public func getSingle(id: String) -> T? {
//        let realm = try! Realm()
        return try? realm.object(ofType: T.StoreType.self, forPrimaryKey: id)?.toDomain(fields: Set(T.StoreType.FieldType.allCases)) ?? nil
    }

    public func getList(predicate: NSPredicate = NSPredicate(value: true)) -> [T] {
//        let realm = try! Realm()
        return try! realm.objects(T.StoreType.self).filter(predicate).compactMap {try $0.toDomain(fields: Set(T.StoreType.FieldType.allCases))}
    }

    public func observeSingle(id: String) -> AnyPublisher<T?, Never> {
//        let realm = try! Realm()
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
//        let realm = try! Realm()
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
