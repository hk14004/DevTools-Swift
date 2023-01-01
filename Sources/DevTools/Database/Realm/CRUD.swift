//
//  CRUD.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation
import RealmSwift

extension Realm {
    func bulkWrite(writeOperation: ()->()) {
        if isInWriteTransaction {
            writeOperation()
        } else {
            try! write {
                writeOperation()
            }
        }
    }
    
    func deleteArchived<T: Object & Archivable>(ofType type: T.Type) {
        bulkWrite(writeOperation: {
            let items = objects(type.self).filter("isArchived == true")
            delete(items)
        })
    }
    
    func archiveItems<T: Object & Archivable>(ofType type: T, identifiers: [String]? = nil) {
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
    
    typealias DatabaseItemType = Object & UnequallyPersistable & Archivable & PartialyUpdateable & AnyObject
    func updateItems<T: DatabaseItemType>(ofType type: T, withJSONList list: [NSDictionary], itemFields: Set<T.T>,
                                          JSONPrimaryKeyField: String = "id", generatePrimaryKeyIfNotFound: Bool,
                                          updateOnlyWhenJSONFieldDataExists: Bool, addIfNewItem: Bool) {
        bulkWrite(writeOperation: {
            list.forEach { json in
                updateItem(ofType: type, withJSON: json, itemFields: itemFields, JSONPrimaryKeyField: JSONPrimaryKeyField,
                           generatePrimaryKeyIfNotFound: generatePrimaryKeyIfNotFound,
                           updateOnlyWhenJSONFieldDataExists: updateOnlyWhenJSONFieldDataExists,
                           addIfNewItem: addIfNewItem)
            }
        })
    }
    
    func updateItem<T: DatabaseItemType>(ofType type: T, withJSON data: NSDictionary, itemFields: Set<T.T>,
                                          JSONPrimaryKeyField: String = "id", generatePrimaryKeyIfNotFound: Bool,
                                          updateOnlyWhenJSONFieldDataExists: Bool, addIfNewItem: Bool) {
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
            if addIfNewItem {
                let new = T.init()
                new.id = itemPrimaryKey
                add(new)
                dbObject = new
            }
        }
        
        dbObject?.updateFields(withJson: data,
                               fields: itemFields,
                               updateOnlyWhenFieldDataExists: updateOnlyWhenJSONFieldDataExists)
    }
}
