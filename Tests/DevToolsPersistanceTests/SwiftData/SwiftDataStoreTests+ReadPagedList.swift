//
//  SwiftDataStoreTests+ReadPagedList.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest
import DevToolsCore

extension SwiftDataStoreTests {
    // MARK: Sync (no write setup)
    func test_readPagedListSync_nothingFound_emptyDB() throws {
        let result = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 0))
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }

    // MARK: Async
    func test_readPagedListAsync_nothingFound_emptyDB() async throws {
        let result = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 0))
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }

    func test_readPagedListAsync_consumedAll_noNextPage() async throws {
        let allItems = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        let result = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 3))
        XCTAssertEqual(result.pageItems, allItems)
        XCTAssertFalse(result.hasNextPage)
    }

    func test_readPagedListAsync_consumedSome_hasNextPage() async throws {
        let allItems = MockSD_DTO.mocks(count: 10)
        try await sut.addOrUpdate(allItems)
        let result = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 9))
        XCTAssertEqual(result.pageItems, Array(allItems[0..<9]))
        XCTAssertTrue(result.hasNextPage)
    }

    func test_readPagedListAsync_consumedAllPages() async throws {
        let pageSize = 3
        let allItems = MockSD_DTO.mocks(count: 10)
        try await sut.addOrUpdate(allItems)
        let page1 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: pageSize))
        let page2 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 2, pageSize: pageSize))
        let page3 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 3, pageSize: pageSize))
        let page4 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 4, pageSize: pageSize))
        XCTAssertEqual(page1.pageItems, Array(allItems[0..<3]));  XCTAssertTrue(page1.hasNextPage)
        XCTAssertEqual(page2.pageItems, Array(allItems[3..<6]));  XCTAssertTrue(page2.hasNextPage)
        XCTAssertEqual(page3.pageItems, Array(allItems[6..<9]));  XCTAssertTrue(page3.hasNextPage)
        XCTAssertEqual(page4.pageItems, Array(allItems[9..<10])); XCTAssertFalse(page4.hasNextPage)
    }

    func test_readPagedListAsync_nothingFound_incorrectID() async throws {
        let allItems = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        let result = try await sut.getListPage(
            pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 9),
            predicate: makeIDPredicate(Constant.randomSuffix)
        )
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }
}
