//
//  CoreDataStoreTests+WriteRegressions.swift
//  DevTools
//

import Foundation
import XCTest

extension CoreDataStoreTests {

    /// Regression: after a successful bulkWrite, subsequent individual writes must still persist.
    func test_writeAsync_afterBulkWrite_persistsCorrectly() async throws {
        let bulkItems = MockCD_DTO.mocks(count: 3)
        try await sut.bulkWrite {
            try await self.sut.addOrUpdate(bulkItems)
        }

        let lateItem = MockCD_DTO(id: "late", name: "late")
        try await sut.addOrUpdate([lateItem])

        let found = try await sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Write after bulkWrite was silently skipped")
    }

    func test_deleteAsync_afterBulkWrite_persistsCorrectly() async throws {
        let items = MockCD_DTO.mocks(count: 3)
        try await sut.addOrUpdate(items)

        try await sut.bulkWrite {
            try await self.sut.addOrUpdate([MockCD_DTO(id: "bulk", name: "bulk")])
        }

        try await sut.delete([items[0].id])

        let found = try await sut.getSingle(id: items[0].id)
        XCTAssertNil(found, "Delete after bulkWrite was silently skipped")
    }
}
