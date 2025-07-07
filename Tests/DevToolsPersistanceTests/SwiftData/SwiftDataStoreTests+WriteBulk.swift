//
//  SwiftDataStoreTests+WriteReplace.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {
    // MARK: Sync
    func test_bulkWriteSync_writeNothing() throws {
        // Arrange
        // Act
        try sut.bulkWrite {}
        
        // Assert
        let result = try sut.getList()
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_bulkWriteSync_writesData() throws {
        // Arrange
        let generated = MockSD_DTO.mocks(count: 99)
        
        // Act
        try sut.bulkWrite {
            try self.sut.replace(with: generated)
            try self.sut.addOrUpdate([self.mockDTO])
        }
        
        // Assert
        let result = try sut.getList()
        XCTAssertEqual(result.count, generated.count + 1)
    }
    
    // MARK: Async
    func test_bulkWriteAsync_writeNothing() async throws {
        // Arrange
        // Act
        try await sut.bulkWrite {}
        
        // Assert
        let result = try await sut.getList()
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_bulkWriteAsync_writesData() async throws {
        // Arrange
        let generated = MockSD_DTO.mocks(count: 99)
        
        // Act
        try await sut.bulkWrite {
            try self.sut.replace(with: generated)
            try self.sut.addOrUpdate([self.mockDTO])
        }
        
        // Assert
        let result = try await sut.getList()
        XCTAssertEqual(result.count, generated.count + 1)
    }
}
