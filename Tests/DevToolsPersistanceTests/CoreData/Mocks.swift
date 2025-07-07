//
//  Mocks.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import DevToolsPersistance
import CoreData

public struct MockCD_DTO: Equatable {
    public let id: String
    public let name: String
}

extension MockCD_DTO: DevDBInterfaceDTO {
    public typealias StoreType = MockCD
}

extension MockCD: DevDBStoredObject {}

extension MockCD_DTO {
    static func mocks(count: Int) -> [MockCD_DTO] {
        return Array(1...count).map { index in
            return MockCD_DTO(id: "\(index)", name: "\(index)")
        }
    }
}

struct MockCD_Converter: DevModelConverter {
    func domainObject(from persistedModel: MockCD) throws -> MockCD_DTO {
        .init(id: persistedModel.id ?? "", name: persistedModel.name ?? "")
    }
    
    func persistableObject(from domainModel: MockCD_DTO) throws -> MockCD {
        MockCD()
    }
    
    func updatePersistedObject(with domainModel: MockCD_DTO, object: MockCD) throws {
        object.id = domainModel.id
        object.name = domainModel.name
    }
}
