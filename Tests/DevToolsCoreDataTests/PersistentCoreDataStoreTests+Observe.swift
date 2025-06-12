//
//  PersistentCoreDataStoreTests+Observe.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension PersistentCoreDataStoreTests {
    func test_observeItem_emptyDB() throws {
        // Arrange
        let expectation = expectation(description: "Receive nil")
        var receivedValue: MockDTO? = nil
        // Act
        sut.observeSingle(id: mockDTO.id)
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertNil(receivedValue)
    }
    
    func test_observeItem_hasRecord() throws {
        // Arrange
        try sut.addOrUpdate([mockDTO])
        let expectation = expectation(description: "Receive persisted value")
        var receivedValue: MockDTO? = nil
        // Act
        sut.observeSingle(id: mockDTO.id)
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertEqual(receivedValue, mockDTO)
    }
    
    func test_observeItem_receivedUpdate() throws {
        // Arrange
        try sut.addOrUpdate([mockDTO])
        let expectation = expectation(description: "Receive updated value")
        var receivedValue: MockDTO? = nil
        let updatedItem = MockDTO(id: mockDTO.id, name: "nameUpdated!")
        // Act
        sut.observeSingle(id: mockDTO.id)
            .dropFirst()
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)
        
        try sut.addOrUpdate([updatedItem])
        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertEqual(receivedValue, updatedItem)
    }
    
    func test_observeItem_itemDeleted() throws {
        // Arrange
        try sut.addOrUpdate([mockDTO])
        let expectation = expectation(description: "Receive value nil after deletion")
        var receivedValue: MockDTO? = nil
        // Act
        sut.observeSingle(id: mockDTO.id)
            .dropFirst()
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)
        
        try sut.replace(with: [])
        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertNil(receivedValue)
    }
}
