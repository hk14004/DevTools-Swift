//
//  PersistentCoreDataStoreTests+ReadList.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension PersistentCoreDataStoreTests {
    // MARK: Sync
    func test_readListSync_nothingFound_emptyDB() throws {
        // Arrange
        // Act
        let result = try sut.getList(predicate: makeIDPredicate(mockDTO.id))

        // Assert
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_readListSync_found() throws {
        // Arrange
        let allItems = MockDTO.mocks(count: 3)
        let itemsToFind: [MockDTO] = [allItems[0], allItems[2]]
        let compoundPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: itemsToFind.map { item in
                makeIDPredicate(item.id)
            }
        )
        
        try sut.addOrUpdate(allItems)
        
        // Act
        let result = try sut.getList(predicate: compoundPredicate)
        
        // Assert
        XCTAssertEqual(result, itemsToFind)
    }
    
    func test_readListSync_nothingFound_incorrectID() throws {
        // Arrange
        let allItems = MockDTO.mocks(count: 3)
        try sut.addOrUpdate(allItems)
        
        // Act
        let result = try sut.getList(predicate: makeIDPredicate(Constant.randomSuffix))
        
        // Assert
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: Async
    func test_readListAsync_nothingFound_emptyDB() async throws {
        // Arrange
        // Act
        let result = try await sut.getList(predicate: makeIDPredicate(mockDTO.id))

        // Assert
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_readListAsync_found() async throws {
        // Arrange
        let allItems = MockDTO.mocks(count: 3)
        let itemsToFind: [MockDTO] = [allItems[0], allItems[2]]
        let compoundPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: itemsToFind.map { item in
                makeIDPredicate(item.id)
            }
        )
        
        try await sut.addOrUpdate(allItems)
        
        // Act
        let result = try await sut.getList(predicate: compoundPredicate)
        
        // Assert
        XCTAssertEqual(result, itemsToFind)
    }
    
    func test_readListAsync_nothingFound_incorrectID() async throws {
        // Arrange
        let allItems = MockDTO.mocks(count: 3)
        try await sut.addOrUpdate(allItems)
        
        // Act
        let result = try await sut.getList(predicate: makeIDPredicate(Constant.randomSuffix))
        
        // Assert
        XCTAssertTrue(result.isEmpty)
    }
}
