//
//  PartialyObservable.swift
//  
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import RealmSwift

public protocol OservableField: RawRepresentable, CaseIterable, Hashable where RawValue == String {

}

public protocol PartialyObservable: AnyObject where Self: Object {
    associatedtype FieldType: OservableField
    associatedtype ObjectType: Object
    func observe(fields: Set<FieldType>, closure:(ObjectChange<ObjectType>) -> Void) -> NotificationToken
}


extension PartialyObservable {
    public func observe(fields: Set<FieldType>, closure: @escaping (ObjectChange<ObjectType>) -> Void) -> NotificationToken {
        let keyPaths = fields.map { field in
            field.rawValue
        }
        return observe(keyPaths: keyPaths, closure)
    }
}
