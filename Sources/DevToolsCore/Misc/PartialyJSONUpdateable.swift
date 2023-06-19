//
//  PartialyUpdateable.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation

public protocol PartialyJSONUpdateable: AnyObject {
    associatedtype T: JSONMappedField
    func updateFields(withJson json: NSDictionary, fields: Set<T>, updateOnlyWhenFieldDataExists: Bool)
}

public protocol JSONMappedField: CaseIterable, Hashable {
    func getKnownJSONKeys() -> [String]
    func getFieldValue(fromJSON json: NSDictionary) -> Any?
}

extension JSONMappedField {
    public func getFieldValue(fromJSON json: NSDictionary) -> Any? {
        let knownKeys = getKnownJSONKeys()
        var extractedValue: Any? = nil
        
        knownKeys.forEach { knownKey in
            if let gotValue = json.value(forKey: knownKey) {
                extractedValue = gotValue
                return // Get the first match and return
            }
        }

        return extractedValue
    }
}

extension Set where Element: JSONMappedField {
    subscript(field: Element) -> Element? {
        get {
            return self.first { $0 == field }
        }
        set {
            if let newValue = newValue {
                update(with: newValue)
            } else {
                remove(field)
            }
        }
    }
}

class ExamplePartialyUpdatableObject {
    
    var fullName: String = ""
    var birthDate: Date = Date()
    
}

extension ExamplePartialyUpdatableObject: PartialyJSONUpdateable {
    
    enum Field: JSONMappedField {
        case fullName
        case birthDate
        
        func getKnownJSONKeys() -> [String] {
            switch self {
            case .fullName:
                return ["full_name", "name_full"]
            case .birthDate:
                return ["birth_date"]
            }
        }
        
    }
    
    func updateFields(withJson json: NSDictionary, fields: Set<Field>, updateOnlyWhenFieldDataExists: Bool) {
        fields.forEach { field in
            switch field {
            case .fullName:
                if updateOnlyWhenFieldDataExists {
                    if let v = field.getFieldValue(fromJSON: json) as? String {
                        fullName = v
                    }
                } else {
                    fullName = field.getFieldValue(fromJSON: json) as? String ?? ""
                }
            case .birthDate:
                if updateOnlyWhenFieldDataExists {
                    if let v = field.getFieldValue(fromJSON: json) as? Date {
                        birthDate = v
                    }
                } else {
                    birthDate = field.getFieldValue(fromJSON: json) as? Date ?? Date()
                }
            }
        }
    }
}
