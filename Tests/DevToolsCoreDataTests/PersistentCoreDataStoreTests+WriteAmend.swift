//
//  PersistentCoreDataStoreTests+WriteAmend.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension PersistentCoreDataStoreTests {
    // MARK: Sync
    // Amend
    func test_writeSync_emptyList() throws {
        // Arrange
        // Act
        try sut.addOrUpdate([])
        // Assert
    }
    
    func test_writeSync_addMultipleItems() throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        // Act
        try sut.addOrUpdate(items)
        // Assert
        let found = try sut.getList()
        XCTAssertEqual(found, items)
    }
    
    func test_writeSync_updateItem() throws {
        // Arrange
        let initialItem = MockDTO(id: "0", name: "updateMe")
        let updatedItem = MockDTO(id: "0", name: "updated")
        try sut.addOrUpdate([initialItem])
        
        // Act
        try sut.addOrUpdate([updatedItem])
        // Assert
        
        let found = try sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }
    
    // MARK: Async
    // Amend
    func test_writeAsync_emptyList() async throws {
        // Arrange
        // Act
        try await sut.addOrUpdate([])
        // Assert
    }
    
    func test_writeAsync_addMultipleItems() async throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        // Act
        try await sut.addOrUpdate(items)
        // Assert
        let found = try await sut.getList()
        XCTAssertEqual(found, items)
    }
    
    func test_writeAsync_updateItem() async throws {
        // Arrange
        let initialItem = MockDTO(id: "0", name: "updateMe")
        let updatedItem = MockDTO(id: "0", name: "updated")
        try await sut.addOrUpdate([initialItem])
        
        // Act
        try await sut.addOrUpdate([updatedItem])
        // Assert
        
        let found = try await sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }
}
