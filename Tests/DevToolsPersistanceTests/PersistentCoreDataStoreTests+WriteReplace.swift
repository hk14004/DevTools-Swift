//
//  PersistentCoreDataStoreTests+WriteReplace.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension PersistentCoreDataStoreTests {
    // MARK: Sync
    func test_replaceSync_emptyList() throws {
        // Arrange
        // Act
        try sut.replace(with: [])
        // Assert
    }
    
    func test_replaceSync_withEmpty() throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        // Act
        try sut.replace(with: [])
        // Assert
        let found = try sut.getList()
        XCTAssertTrue(found.isEmpty)
    }
    
    func test_replaceSync_withItems() throws {
        // Arrange
        let items = MockDTO.mocks(count: 9)
        let replacedWithItems = MockDTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        // Act
        try sut.replace(with: replacedWithItems)
        // Assert
        let found = try sut.getList()
        XCTAssertEqual(replacedWithItems, found)
    }
    
    // MARK: Async
    func test_replaceAsync_emptyList() async throws {
        // Arrange
        // Act
        try await sut.replace(with: [])
        // Assert
    }
    
    func test_replaceAsync_withEmpty() async throws {
        // Arrange
        let items = MockDTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        // Act
        try await sut.replace(with: [])
        // Assert
        let found = try await sut.getList()
        XCTAssertTrue(found.isEmpty)
    }
    
    func test_replaceAsync_withItems() async throws {
        // Arrange
        let items = MockDTO.mocks(count: 9)
        let replacedWithItems = MockDTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        // Act
        try await sut.replace(with: replacedWithItems)
        // Assert
        let found = try await sut.getList()
        XCTAssertEqual(replacedWithItems, found)
    }
}
