//
//  Mocks.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import DevToolsPersistance
import SwiftData

public struct MockSD_DTO: Equatable {
    public let id: String
    public let name: String
}

extension MockSD_DTO: DevDBInterfaceDTO {
    public typealias StoreType = MockSD
}

@Model
public class MockSD {
    public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension MockSD: DevDBStoredObject {}

extension MockSD_DTO {
    static func mocks(count: Int) -> [MockSD_DTO] {
        return Array(1...count).map { index in
            return MockSD_DTO(id: "\(index)", name: "\(index)")
        }
    }
}

struct MockSD_Converter: DevModelConverter {
    func persistableObject(from domainModel: MockSD_DTO) throws -> MockSD {
        MockSD(id: domainModel.id, name: domainModel.name)
    }
    
    func domainObject(from persistedModel: MockSD) throws -> MockSD_DTO {
        .init(id: persistedModel.id, name: persistedModel.name)
    }
    
    func updatePersistedObject(with domainModel: MockSD_DTO, object: MockSD) throws {
        object.id = domainModel.id
        object.name = domainModel.name
    }
}
