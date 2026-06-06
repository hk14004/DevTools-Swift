//
//  SwiftDataStoreTests+WriteAmend.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {

    func test_writeAsync_addMultipleItems() async throws {
        let items = MockSD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)
        let found = try await sut.getList()
        XCTAssertEqual(found, items)
    }

    func test_writeAsync_updateItem() async throws {
        let initialItem = MockSD_DTO(id: "0", name: "updateMe")
        let updatedItem = MockSD_DTO(id: "0", name: "updated")
        try await sut.addOrUpdate([initialItem])
        try await sut.addOrUpdate([updatedItem])
        let found = try await sut.getSingle(id: initialItem.id)
        XCTAssertEqual(found?.name, updatedItem.name)
    }

    func test_writeAsync_mixedUpsert() async throws {
        let a = MockSD_DTO(id: "A", name: "a")
        let b = MockSD_DTO(id: "B", name: "b")
        let c = MockSD_DTO(id: "C", name: "c")
        let bUpdated = MockSD_DTO(id: "B", name: "b-updated")
        let d = MockSD_DTO(id: "D", name: "d")
        try await sut.addOrUpdate([a, b, c])

        try await sut.addOrUpdate([bUpdated, d])

        let found = try await sut.getList()
        let foundA = try await sut.getSingle(id: "A")
        let foundB = try await sut.getSingle(id: "B")
        let foundC = try await sut.getSingle(id: "C")
        let foundD = try await sut.getSingle(id: "D")
        XCTAssertEqual(found.count, 4)
        XCTAssertEqual(foundA, a)
        XCTAssertEqual(foundB, bUpdated)
        XCTAssertEqual(foundC, c)
        XCTAssertEqual(foundD, d)
    }
}
