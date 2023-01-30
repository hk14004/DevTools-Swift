//
//  File.swift
//  
//
//  Created by Cube on 30/01/2023.
//

import Foundation

// All persistent entities should implement this protocol

public protocol PersistedModelProtocol: AnyObject, Identifiable {
    associatedtype DomainModel: PersistableDomainModelProtocol
    associatedtype F: PersistedModelField
    
    func toDomain() -> DomainModel
    func update(with model: DomainModel)
    func partialUpdate(with model: DomainModel, fields: Set<F>)
    
}

public protocol PersistedModelField: CaseIterable, Hashable {

}
