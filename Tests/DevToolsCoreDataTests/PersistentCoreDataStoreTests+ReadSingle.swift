//
//  PersistentCoreDataStoreTests+ReadSingle.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension PersistentCoreDataStoreTests {
    // MARK: Sync
    func test_readSingleSync_nothingFound_emptyDB() throws {
        // Arrange
        // Act
        let result = try sut.getSingle(id: mockDTO.id)
        
        // Assert
        XCTAssertNil(result)
    }
    
    func test_readSingleSync_found() throws {
        // Arrange
        try sut.addOrUpdate([mockDTO])
        
        // Act
        let result = try sut.getSingle(id: mockDTO.id)
        
        // Assert
        XCTAssertEqual(result, mockDTO)
    }
    
    func test_readSingleSync_nothingFound_incorrectID() throws {
        // Arrange
        try sut.addOrUpdate([mockDTO])
        
        // Act
        let result = try sut.getSingle(id: mockDTO.id + Constant.randomSuffix)
        
        // Assert
        XCTAssertNil(result)
    }
    
    // MARK: Async
    func test_readSingleAsync_nothingFound_emptyDB() async throws {
        // Arrange
        // Act
        let result = try await sut.getSingle(id: mockDTO.id)
        
        // Assert
        XCTAssertNil(result)
    }
    
    func test_readSingleAsync_found() async throws {
        // Arrange
        try await sut.addOrUpdate([mockDTO])
        
        // Act
        let result = try await sut.getSingle(id: mockDTO.id)
        
        // Assert
        XCTAssertEqual(result, mockDTO)
    }
    
    func test_readSingleAsync_nothingFound_incorrectID() async throws {
        // Arrange
        try await sut.addOrUpdate([mockDTO])
        
        // Act
        let result = try await sut.getSingle(id: mockDTO.id + Constant.randomSuffix)
        
        // Assert
        XCTAssertNil(result)
    }
}
