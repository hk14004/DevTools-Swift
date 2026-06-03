//
//  SwiftDataStoreTests+WriteAmend.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {
    // MARK: Sync
    // Amend
    func test_writeSync_addMultipleItems() throws {
        // Arrange
        let items = MockSD_DTO.mocks(count: 3)
        // Act
        try sut.addOrUpdate(items)
        // Assert
        let found = try sut.getList()
        XCTAssertEqual(found, items)
    }
    
    func test_writeSync_updateItem() throws {
        // Arrange
        let initialItem = MockSD_DTO(id: "0", name: "updateMe")
        let updatedItem = MockSD_DTO(id: "0", name: "updated")
        try sut.addOrUpdate([initialItem])
        
        // Act
        try sut.addOrUpdate([updatedItem])
        // Assert
        
        let found = try sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }
    
    func test_writeSync_mixedUpsert() throws {
        // Arrange: seed A, B, C — then call addOrUpdate with B (updated) + D (new)
        let a = MockSD_DTO(id: "A", name: "a")
        let b = MockSD_DTO(id: "B", name: "b")
        let c = MockSD_DTO(id: "C", name: "c")
        let bUpdated = MockSD_DTO(id: "B", name: "b-updated")
        let d = MockSD_DTO(id: "D", name: "d")
        try sut.addOrUpdate([a, b, c])

        // Act
        try sut.addOrUpdate([bUpdated, d])

        // Assert: A and C untouched, B updated, D inserted
        let found = try sut.getList()
        XCTAssertEqual(found.count, 4)
        XCTAssertEqual(try sut.getSingle(id: "A"), a)
        XCTAssertEqual(try sut.getSingle(id: "B"), bUpdated)
        XCTAssertEqual(try sut.getSingle(id: "C"), c)
        XCTAssertEqual(try sut.getSingle(id: "D"), d)
    }

    // MARK: Async
    // Amend
    func test_writeAsync_addMultipleItems() async throws {
        // Arrange
        let items = MockSD_DTO.mocks(count: 3)
        // Act
        try await sut.addOrUpdate(items)
        // Assert
        let found = try await sut.getList()
        XCTAssertEqual(found, items)
    }
    
    func test_writeAsync_updateItem() async throws {
        // Arrange
        let initialItem = MockSD_DTO(id: "0", name: "updateMe")
        let updatedItem = MockSD_DTO(id: "0", name: "updated")
        try await sut.addOrUpdate([initialItem])
        
        // Act
        try await sut.addOrUpdate([updatedItem])
        // Assert
        
        let found = try await sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }
}
