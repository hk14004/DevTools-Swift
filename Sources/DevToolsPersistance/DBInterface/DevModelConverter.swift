//
//  DevModelConverter.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 04/07/2025.
//

import Foundation

public protocol DevModelConverter {
    associatedtype DomainType: DevDBInterfaceDTO
    associatedtype PersistedType: DBStoredObject
    
    func domainObject(from persistedModel: PersistedType) throws -> DomainType
    func updatePersistedObject(with domainModel: DomainType, object: PersistedType) throws
}
