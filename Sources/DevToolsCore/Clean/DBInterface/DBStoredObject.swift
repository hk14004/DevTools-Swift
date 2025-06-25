//
//  DBStoredObject.swift
//
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation

public protocol DBStoredObject: AnyObject, Identifiable {
    associatedtype DomainDTO: DBInterfaceDTO
    associatedtype FieldType: DBObjectField
    
    func convert(fields: Set<FieldType>) throws -> DomainDTO
    func update(with model: DomainDTO, fields: Set<FieldType>)
}
