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

extension MockDTO: PersistableDomainModel {
    public typealias StoreType = MockCD
}

extension MockCD: PersistedModel {
    public enum Field: String, PersistedModelField {
        case id
        case name
    }
    
    public func toDomain(fields: Set<Field>) throws -> MockDTO {
        .init(id: self.id ?? "", name: self.name ?? "")
    }
    
    public func update(with model: MockDTO, fields: Set<Field>) {
        self.id = model.id
        self.name = model.name
    }
}

extension MockDTO {
    static func mocks(count: Int) -> [MockDTO] {
        return Array(1...count).map { index in
            return MockDTO(id: "\(index)", name: "\(index)")
        }
    }
}
