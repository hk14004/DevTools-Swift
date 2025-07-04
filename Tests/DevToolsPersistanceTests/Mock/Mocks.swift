//
//  Mocks.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import DevToolsCore
import CoreData

public struct MockDTO: Equatable {
    public let id: String
    public let name: String
}

extension MockDTO: DBInterfaceDTO {
    public typealias StoreType = MockCD
}

extension MockCD: DBStoredObject {}

extension MockDTO {
    static func mocks(count: Int) -> [MockDTO] {
        return Array(1...count).map { index in
            return MockDTO(id: "\(index)", name: "\(index)")
        }
    }
}

struct MockConverter: ModelConverter {
    func domainObject(from persistedModel: MockCD) throws -> MockDTO {
        .init(id: persistedModel.id ?? "", name: persistedModel.name ?? "")
    }
    
    func persistableObject(from domainModel: MockDTO) throws -> MockCD {
        MockCD()
    }
    
    func updatePersistedObject(with domainModel: MockDTO, object: MockCD) throws {
        object.id = domainModel.id
        object.name = domainModel.name
    }
}
