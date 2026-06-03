//
//  SwiftDataStoreTests+Observe.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {

    // MARK: Single

    func test_observeItem_emptyDB() throws {
        let expectation = expectation(description: "Receive nil")
        var receivedValue: MockSD_DTO? = nil

        sut.observeSingle(id: mockDTO.id)
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        XCTAssertNil(receivedValue)
    }

    func test_observeItem_hasRecord() async throws {
        try await sut.addOrUpdate([mockDTO])
        let expectation = expectation(description: "Receive persisted value")
        var receivedValue: MockSD_DTO? = nil

        sut.observeSingle(id: mockDTO.id)
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(receivedValue, mockDTO)
    }

    func test_observeItem_receivedUpdate() async throws {
        try await sut.addOrUpdate([mockDTO])
        let updatedItem = MockSD_DTO(id: mockDTO.id, name: "nameUpdated!")
        let expectation = expectation(description: "Receive updated value")
        var receivedValue: MockSD_DTO? = nil

        sut.observeSingle(id: mockDTO.id)
            .dropFirst()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        try await sut.addOrUpdate([updatedItem])
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertEqual(receivedValue, updatedItem)
    }

    func test_observeItem_itemDeleted() async throws {
        try await sut.addOrUpdate([mockDTO])
        let expectation = expectation(description: "Receive nil after deletion")
        var receivedValue: MockSD_DTO? = nil

        sut.observeSingle(id: mockDTO.id)
            .dropFirst()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        try await sut.replace(with: [])
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertNil(receivedValue)
    }

    // MARK: List

    func test_observeList_emptyDB() throws {
        let expectation = expectation(description: "Receive empty list")
        var receivedValue: [MockSD_DTO] = []

        sut.observeList()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: 1)
        XCTAssertTrue(receivedValue.isEmpty)
    }

    func test_observeList_hasRecords() async throws {
        let items = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        let expectation = expectation(description: "Receive persisted values")
        var receivedValue: [MockSD_DTO] = []

        sut.observeList()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(receivedValue, items)
    }

    func test_observeItems_receivedUpdate() async throws {
        let items = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        let updatedItem = MockSD_DTO(id: items[1].id, name: "nameUpdated!")
        let updatedList: [MockSD_DTO] = [items[0], updatedItem, items[2]]
        let expectation = expectation(description: "Receive updated values")
        var receivedValue: [MockSD_DTO] = []

        sut.observeList()
            .dropFirst()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        try await sut.addOrUpdate([updatedItem])
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertEqual(receivedValue, updatedList)
    }

    func test_observeList_itemsDeleted() async throws {
        let items = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        let expectation = expectation(description: "Receive empty list after deletion")
        var receivedValue: [MockSD_DTO] = []

        sut.observeList()
            .dropFirst()
            .sink { _ in XCTFail() } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancelBag)

        try await sut.replace(with: [])
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(receivedValue.isEmpty)
    }
}
