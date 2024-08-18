//
//  PersistedModel.swift
//  
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation

// All persistent entities should implement this protocol

public protocol PersistedModel: AnyObject, Identifiable {
    associatedtype DomainModelType: PersistableDomainModel
    associatedtype FieldType: PersistedModelField
    
    func toDomain(fields: Set<FieldType>) throws -> DomainModelType
    func update(with model: DomainModelType, fields: Set<FieldType>)
    
}

public protocol PersistedModelField: CaseIterable, Hashable {}

extension PersistedModelField {
    public static func getSetOfAllFields() -> Set<Self> {
        Set(Self.allCases)
    }
}
