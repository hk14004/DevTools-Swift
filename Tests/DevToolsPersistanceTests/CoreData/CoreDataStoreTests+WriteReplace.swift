//
//  PersistentCoreDataStoreTests+WriteReplace.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension CoreDataStoreTests {

    func test_replaceAsync_withEmpty() async throws {
        let items = MockCD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        try await sut.replace(with: [])
        let found = try await sut.getList()
        XCTAssertTrue(found.isEmpty)
    }

    func test_replaceAsync_withItems() async throws {
        let items = MockCD_DTO.mocks(count: 9)
        let replacedWithItems = MockCD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        try await sut.replace(with: replacedWithItems)
        let found = try await sut.getList()
        XCTAssertEqual(replacedWithItems, found)
    }
}
