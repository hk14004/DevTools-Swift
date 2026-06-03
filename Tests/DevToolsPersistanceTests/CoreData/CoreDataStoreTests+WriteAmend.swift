//
//  PersistentCoreDataStoreTests+WriteAmend.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension CoreDataStoreTests {

    func test_writeAsync_addMultipleItems() async throws {
        let items = MockCD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        let found = try await sut.getList()
        XCTAssertEqual(found, items)
    }

    func test_writeAsync_updateItem() async throws {
        let initialItem = MockCD_DTO(id: "0", name: "updateMe")
        let updatedItem = MockCD_DTO(id: "0", name: "updated")
        try await sut.addOrUpdate([initialItem])
        try await sut.addOrUpdate([updatedItem])
        let found = try await sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }

    func test_writeAsync_mixedUpsert() async throws {
        let a = MockCD_DTO(id: "A", name: "a")
        let b = MockCD_DTO(id: "B", name: "b")
        let c = MockCD_DTO(id: "C", name: "c")
        let bUpdated = MockCD_DTO(id: "B", name: "b-updated")
        let d = MockCD_DTO(id: "D", name: "d")
        try await sut.addOrUpdate([a, b, c])

        try await sut.addOrUpdate([bUpdated, d])

        let found = try await sut.getList()
        XCTAssertEqual(found.count, 4)
        XCTAssertEqual(try await sut.getSingle(id: "A"), a)
        XCTAssertEqual(try await sut.getSingle(id: "B"), bUpdated)
        XCTAssertEqual(try await sut.getSingle(id: "C"), c)
        XCTAssertEqual(try await sut.getSingle(id: "D"), d)
    }
}
