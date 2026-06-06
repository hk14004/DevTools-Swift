//
//  PersistentCoreDataStoreTests+WriteDelete.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension CoreDataStoreTests {

    func test_deleteAsync_allItems() async throws {
        let items = MockCD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        try await sut.delete(items.map { $0.id })
        let found = try await sut.getList()
        XCTAssertTrue(found.isEmpty)
    }

    func test_deleteAsync_partial() async throws {
        let items = MockCD_DTO.mocks(count: 3)
        var expectedItems = items
        expectedItems.remove(at: 1)
        try await sut.addOrUpdate(items)
        try await sut.delete([items[1].id])
        let found = try await sut.getList()
        XCTAssertEqual(found, expectedItems)
    }
}
