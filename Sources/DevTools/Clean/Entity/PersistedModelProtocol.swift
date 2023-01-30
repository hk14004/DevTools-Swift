//
//  File.swift
//  
//
//  Created by Cube on 30/01/2023.
//

import Foundation

// All persistent entities should implement this protocol

public protocol PersistedModelProtocol: AnyObject, Identifiable, PartialyUpdateable {
    associatedtype DomainModel: PersistableDomainModelProtocol
    
    func toDomain() -> DomainModel
    func update(with model: DomainModel)
    // TODO: Partially updatable
    
}
