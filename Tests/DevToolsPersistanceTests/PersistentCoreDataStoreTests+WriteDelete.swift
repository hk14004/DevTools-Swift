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
    func test_deleteSync_emptyList() throws {
        // Arrange
        // Act
        try sut.delete([])
        // Assert
    }
    
    func test_deleteSync_allItems() throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        // Act
        try sut.delete(items.map { $0.id } )
        // Assert
        let found = try sut.getList()
        XCTAssertTrue(found.isEmpty)
    }
    
    func test_deleteSync_partial() throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        var expectedItems = items
        expectedItems.remove(at: 1)
        try sut.addOrUpdate(items)
        // Act
        try sut.delete([items[1].id])
        // Assert
        let found = try sut.getList()
        XCTAssertEqual(found, expectedItems)
    }
    
    // MARK: Async
    func test_deleteAsync_emptyList() async throws {
        // Arrange
        // Act
        try await sut.delete([])
        // Assert
    }
    
    func test_deleteSync_allItems() async throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        // Act
        try await sut.delete(items.map { $0.id } )
        // Assert
        let found = try await sut.getList()
        XCTAssertTrue(found.isEmpty)
    }
    
    func test_deleteSync_partial() async throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        var expectedItems = items
        expectedItems.remove(at: 1)
        try await sut.addOrUpdate(items)
        // Act
        try await sut.delete([items[1].id])
        // Assert
        let found = try await sut.getList()
        XCTAssertEqual(found, expectedItems)
    }
}
