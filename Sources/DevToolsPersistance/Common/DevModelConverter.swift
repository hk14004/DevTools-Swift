//
//  DevModelConverter.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation

public protocol DevModelConverter {
    associatedtype DomainType: DevDBInterfaceDTO
    associatedtype PersistedType: DevDBStoredObject
    
    func domainObject(from persistedModel: PersistedType) throws -> DomainType
    func persistableObject(from domainModel: DomainType) throws -> PersistedType
    func updatePersistedObject(with domainModel: DomainType, object: PersistedType) throws
}
