//
//  PartialyUpdateable.swift
//  
//
//  Created by Cube on 01/01/2023.
//

import Foundation

public protocol PartialyUpdateable: AnyObject {
    associatedtype T: MappedField
    func updateFields(withJson json: NSDictionary, fields: Set<T>, updateOnlyWhenFieldDataExists: Bool)
}

public protocol MappedField: CaseIterable, Hashable {
    func getKnownJSONKeys() -> [String]
    func getFieldValue(fromJSON json: NSDictionary) -> Any?
}

extension MappedField {
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

class ExamplePartialyUpdatableObject {
    
    var fullName: String = ""
    var birthDate: Date = Date()
    
}

extension ExamplePartialyUpdatableObject: PartialyUpdateable {
    
    enum Field: MappedField {
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
