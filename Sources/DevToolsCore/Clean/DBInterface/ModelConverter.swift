//
//  ModelConvertor.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation

public protocol ModelConverter {
    associatedtype DomainType: DBInterfaceDTO
    associatedtype PersistedType: DBStoredObject
    
    func domainObject(from persistedModel: PersistedType) throws -> DomainType
    func persistableObject(from domainModel: DomainType) throws -> PersistedType
    func updatePersistedObject(with domainModel: DomainType, object: PersistedType) throws
}
