//
//  SwiftDataStoreTests+WriteAmend.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {
    func test_deleteAsync_allItems() async throws {
        // Arrange
        let items = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        // Act
        try await sut.delete(items.map { $0.id })
        // Assert
        let found = try await sut.getList()
        XCTAssertTrue(found.isEmpty)
    }

    func test_deleteAsync_partial() async throws {
        // Arrange
        let items = MockSD_DTO.mocks(count: 3)
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
