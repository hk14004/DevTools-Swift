//
//  PartialyObservable.swift
//  
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import RealmSwift

public protocol OservableField: RawRepresentable, CaseIterable, Hashable where RawValue == String {

}

public protocol PartialyObservable where Self: Object {
    associatedtype FieldType: OservableField
}


public extension PartialyObservable where Self: Object  {
    func observe(fields: Set<FieldType>, closure: @escaping (ObjectChange<Self>) -> Void) -> NotificationToken {
        let keyPaths = fields.map { field in
            field.rawValue
        }
        return observe(keyPaths: keyPaths, closure)
    }
}
