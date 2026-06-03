//
//  SwiftDataStoreTests+ReadList.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {
    // MARK: Sync (no write setup)
    func test_readListSync_nothingFound_emptyDB() throws {
        let result = try sut.getList(predicate: makeIDPredicate(mockDTO.id))
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: Async
    func test_readListAsync_found() async throws {
        let allItems = MockSD_DTO.mocks(count: 3)
        let itemsToFind: [MockSD_DTO] = [allItems[0], allItems[2]]
        let compoundPredicate = makeIDPredicate(contains: itemsToFind.map(\.id))
        try await sut.addOrUpdate(allItems)
        let result = try await sut.getList(predicate: compoundPredicate)
        XCTAssertEqual(result, itemsToFind)
    }

    func test_readListAsync_nothingFound_incorrectID() async throws {
        let allItems = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        let result = try await sut.getList(predicate: makeIDPredicate(Constant.randomSuffix))
        XCTAssertTrue(result.isEmpty)
    }

    func test_readListAsync_nothingFound_emptyDB() async throws {
        let result = try await sut.getList(predicate: makeIDPredicate(mockDTO.id))
        XCTAssertTrue(result.isEmpty)
    }
}
