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
    // MARK: Sync
    func test_readPagedListSync_nothingFound_emptyDB() throws {
        // Arrange
        // Act
        let result = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 0))

        // Assert
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }
    
    func test_readPagedListSync_consumedAll_noNextPage() throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 3)
        try sut.addOrUpdate(allItems)
        
        // Act
        let result = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 3))
        
        // Assert
        XCTAssertEqual(result.pageItems, allItems)
        XCTAssertFalse(result.hasNextPage)
    }
    
    func test_readPagedListSync_consumedSome_hasNextPage() throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 10)
        let expectedPageItems = Array(allItems[0..<allItems.count - 1])
        try sut.addOrUpdate(allItems)
        
        // Act
        let result = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 9))
        
        // Assert
        XCTAssertEqual(result.pageItems, expectedPageItems)
        XCTAssertTrue(result.hasNextPage)
    }

    func test_readPagedListSync_consumedAllPages() throws {
        // Arrange
        let pageSize: Int = 3
        let allItems = MockSD_DTO.mocks(count: 10)
        let expected1PageItems = Array(allItems[pageSize*0..<pageSize])
        let expected2PageItems = Array(allItems[pageSize*1..<pageSize*2])
        let expected3PageItems = Array(allItems[pageSize*2..<pageSize*3])
        let expected4PageItems = Array(allItems[pageSize*3..<allItems.count])
        try sut.addOrUpdate(allItems)
        
        // Act
        let page1 = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: pageSize))
        let page2 = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 2, pageSize: pageSize))
        let page3 = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 3, pageSize: pageSize))
        let page4 = try sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 4, pageSize: pageSize))
        
        // Assert
        XCTAssertEqual(page1.pageItems, expected1PageItems)
        XCTAssertTrue(page1.hasNextPage)
        XCTAssertEqual(page2.pageItems, expected2PageItems)
        XCTAssertTrue(page2.hasNextPage)
        XCTAssertEqual(page3.pageItems, expected3PageItems)
        XCTAssertTrue(page3.hasNextPage)
        XCTAssertEqual(page4.pageItems, expected4PageItems)
        XCTAssertFalse(page4.hasNextPage)
    }
    
    func test_readPagedListSync_nothingFound_incorrectID() throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 3)
        try sut.addOrUpdate(allItems)
        
        // Act
        let result = try sut.getListPage(
            pageOptions: DevPagedRequestOptions(
                fetchPage: 1,
                pageSize: 9
            ),
            predicate: makeIDPredicate(Constant.randomSuffix)
        )
        
        // Assert
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }
    
    // MARK: Async

    func test_readPagedListAsync_nothingFound_emptyDB() async throws {
        // Arrange
        // Act
        let result = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 0))

        // Assert
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }
    
    func test_readPagedListAsync_consumedAll_noNextPage() async throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        
        // Act
        let result = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 3))
        
        // Assert
        XCTAssertEqual(result.pageItems, allItems)
        XCTAssertFalse(result.hasNextPage)
    }
    
    func test_readPagedListAsync_consumedSome_hasNextPage() async throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 10)
        let expectedPageItems = Array(allItems[0..<allItems.count - 1])
        try await sut.addOrUpdate(allItems)
        
        // Act
        let result = try await  sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: 9))
        
        // Assert
        XCTAssertEqual(result.pageItems, expectedPageItems)
        XCTAssertTrue(result.hasNextPage)
    }

    func test_readPagedListAsync_consumedAllPages() async throws {
        // Arrange
        let pageSize: Int = 3
        let allItems = MockSD_DTO.mocks(count: 10)
        let expected1PageItems = Array(allItems[pageSize*0..<pageSize])
        let expected2PageItems = Array(allItems[pageSize*1..<pageSize*2])
        let expected3PageItems = Array(allItems[pageSize*2..<pageSize*3])
        let expected4PageItems = Array(allItems[pageSize*3..<allItems.count])
        try await sut.addOrUpdate(allItems)
        
        // Act
        let page1 = try await  sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 1, pageSize: pageSize))
        let page2 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 2, pageSize: pageSize))
        let page3 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 3, pageSize: pageSize))
        let page4 = try await sut.getListPage(pageOptions: DevPagedRequestOptions(fetchPage: 4, pageSize: pageSize))
        
        // Assert
        XCTAssertEqual(page1.pageItems, expected1PageItems)
        XCTAssertTrue(page1.hasNextPage)
        XCTAssertEqual(page2.pageItems, expected2PageItems)
        XCTAssertTrue(page2.hasNextPage)
        XCTAssertEqual(page3.pageItems, expected3PageItems)
        XCTAssertTrue(page3.hasNextPage)
        XCTAssertEqual(page4.pageItems, expected4PageItems)
        XCTAssertFalse(page4.hasNextPage)
    }
    
    func test_readPagedListAsync_nothingFound_incorrectID() async throws {
        // Arrange
        let allItems = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        
        // Act
        let result = try await sut.getListPage(
            pageOptions: DevPagedRequestOptions(
                fetchPage: 1,
                pageSize: 9
            ),
            predicate: makeIDPredicate(Constant.randomSuffix)
        )
        
        // Assert
        XCTAssertTrue(result.pageItems.isEmpty)
        XCTAssertFalse(result.hasNextPage)
    }
}
