//
//  Realm + CRUD.swift
//  
//
//  Created by Hardijs Ķirsis on 07/04/2023.
//

import Foundation
import RealmSwift
import DevTools

extension Realm {
    public func bulkWrite(writeOperation: ()->()) {
        if isInWriteTransaction {
            writeOperation()
        } else {
            try! write {
                writeOperation()
            }
        }
    }
    
    public func deleteArchived<T: Object & Archivable>(ofType type: T.Type) {
        bulkWrite(writeOperation: {
            let items = objects(type.self).filter("isArchived == true")
            delete(items)
        })
    }
    
    public func archiveItems<T: Object & Archivable>(ofType type: T.Type, identifiers: [String]? = nil) {
        func archive(_ object: T) {
            object.archive(true)
        }
        bulkWrite(writeOperation: {
            if let _identifiers = identifiers {
                for identifier in _identifiers {
                    guard let object = object(ofType: T.self, forPrimaryKey: identifier) else {
                        continue
                    }
                    archive(object)
                }
            } else {
                let results = objects(T.self)
                for object in results {
                    archive(object)
                }
            }
        })
    }
    
    public func replaceList<T: DatabaseItemType>(ofType type: T.Type, withJSONList list: [NSDictionary], updateFields: Set<T.T>,
                                          JSONPrimaryKeyField: String = "id", generatePrimaryKeyIfNotFound: Bool,
                                          updateOnlyWhenJSONFieldDataExists: Bool) {
        bulkWrite(writeOperation: {
            archiveItems(ofType: type)
            updateItems(ofType: type, withJSONItems: list, updateFields: updateFields,
                        JSONPrimaryKeyField: JSONPrimaryKeyField, generatePrimaryKeyIfNotFound: generatePrimaryKeyIfNotFound,
                        updateOnlyWhenJSONFieldDataExists: updateOnlyWhenJSONFieldDataExists)
        })
    }
    
    public typealias DatabaseItemType = Object & UnequallyPersistable & Archivable & PartialyJSONUpdateable & AnyObject
    public  func updateItems<T: DatabaseItemType>(ofType type: T.Type, withJSONItems items: [NSDictionary], updateFields: Set<T.T>,
                                          JSONPrimaryKeyField: String = "id", generatePrimaryKeyIfNotFound: Bool,
                                          updateOnlyWhenJSONFieldDataExists: Bool) {
        bulkWrite(writeOperation: {
            items.forEach { json in
                updateItem(ofType: type, withJSON: json, updateFields: updateFields, JSONPrimaryKeyField: JSONPrimaryKeyField,
                           generatePrimaryKeyIfNotFound: generatePrimaryKeyIfNotFound,
                           updateOnlyWhenJSONFieldDataExists: updateOnlyWhenJSONFieldDataExists)
            }
        })
    }
    
    public func updateItem<T: DatabaseItemType>(ofType type: T.Type, withJSON data: NSDictionary, updateFields: Set<T.T>,
                                          JSONPrimaryKeyField: String = "id", generatePrimaryKeyIfNotFound: Bool,
                                          updateOnlyWhenJSONFieldDataExists: Bool) {
        bulkWrite(writeOperation: {
            let itemPrimaryKey: String = {
                let id = "\(data[JSONPrimaryKeyField] ?? "")"
                if id.isEmpty, generatePrimaryKeyIfNotFound {
                    return UUID().uuidString
                }
                return id
            }()
            
            guard !itemPrimaryKey.isEmpty else {
                return
            }
            
            var dbObject: T? = object(ofType: T.self, forPrimaryKey: itemPrimaryKey)
            
            if let dbObject = dbObject {
                dbObject.archive(false)
            } else {
                let new = T.init()
                new.id = itemPrimaryKey
                add(new)
                dbObject = new
            }
            
            dbObject?.updateFields(withJson: data,
                                   fields: updateFields,
                                   updateOnlyWhenFieldDataExists: updateOnlyWhenJSONFieldDataExists)
        })
    }
}
