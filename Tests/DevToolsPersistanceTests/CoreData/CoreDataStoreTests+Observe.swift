//
//  PersistentCoreDataStoreTests+Observe.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension CoreDataStoreTests {
    // MARK: Single
    
    func test_observeItem_emptyDB() throws {
        // Arrange
        let expectation = expectation(description: "Receive nil")
        var receivedValue: MockCD_DTO? = nil
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
        var receivedValue: MockCD_DTO? = nil
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
        var receivedValue: MockCD_DTO? = nil
        let updatedItem = MockCD_DTO(id: mockDTO.id, name: "nameUpdated!")
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
        var receivedValue: MockCD_DTO? = nil
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
    
    // MARK: List
    
    func test_observeList_emptyDB() throws {
        // Arrange
        let expectation = expectation(description: "Receive empty list")
        var receivedValue: [MockCD_DTO] = []
        // Act
        sut.observeList()
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertTrue(receivedValue.isEmpty)
    }
    
    func test_observeList_hasRecords() throws {
        // Arrange
        let items = MockCD_DTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        let expectation = expectation(description: "Receive persisted values")
        var receivedValue: [MockCD_DTO] = []
        // Act
        sut.observeList()
            .sink { _ in
                XCTFail()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        
        // Assert
        XCTAssertEqual(receivedValue, items)
    }
    
    func test_observeItems_receivedUpdate() throws {
        // Arrange
        let items = MockCD_DTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        let expectation = expectation(description: "Receive updated values")
        var receivedValue: [MockCD_DTO] = []
        let updatedItem = MockCD_DTO(id: items[1].id, name: "nameUpdated!")
        let updatedList: [MockCD_DTO] = [items[0], updatedItem, items[2]]
        // Act
        sut.observeList()
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
        XCTAssertEqual(receivedValue, updatedList)
    }
    
    func test_observeList_itemsDeleted() throws {
        // Arrange
        let items = MockCD_DTO.mocks(count: 3)
        try sut.addOrUpdate(items)
        let expectation = expectation(description: "Receive empty list")
        var receivedValue: [MockCD_DTO] = []
        // Act
        sut.observeList()
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
        XCTAssertTrue(receivedValue.isEmpty)
    }
}
