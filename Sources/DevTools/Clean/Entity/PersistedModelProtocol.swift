//
//  File.swift
//  
//
//  Created by Cube on 30/01/2023.
//

import Foundation

// All persistent entities should implement this protocol

public protocol PersistedModelProtocol: AnyObject, Identifiable {
    associatedtype DomainModelType: PersistableDomainModelProtocol
    associatedtype FieldType: PersistedModelFieldProtocol
    
    func toDomain(fields: Set<FieldType>) throws -> DomainModelType
    func update(with model: DomainModelType, fields: Set<FieldType>)
    
}

public protocol PersistedModelFieldProtocol: CaseIterable, Hashable {

}
