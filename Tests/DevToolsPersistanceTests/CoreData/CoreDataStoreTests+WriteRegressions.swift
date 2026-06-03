//
//  CoreDataStoreTests+WriteRegressions.swift
//  DevTools
//

import Foundation
import XCTest

extension CoreDataStoreTests {

    /// Regression: after a successful bulkWrite, subsequent individual writes must still persist.
    ///
    /// Previously, `performBulkWriteOperation` reset `bulkWriteInProgress` to `true` instead of
    /// `false` on success, causing every subsequent `addOrUpdate`/`delete`/`replace` to silently
    /// skip its save.
    func test_writeSync_afterBulkWrite_persistsCorrectly() throws {
        let bulkItems = MockCD_DTO.mocks(count: 3)
        try sut.bulkWrite {
            try self.sut.addOrUpdate(bulkItems)
        }

        // This individual write must not be silently dropped.
        let lateItem = MockCD_DTO(id: "late", name: "late")
        try sut.addOrUpdate([lateItem])

        let found = try sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Write after bulkWrite was silently skipped")
    }

    func test_writeAsync_afterBulkWrite_persistsCorrectly() async throws {
        let bulkItems = MockCD_DTO.mocks(count: 3)
        try await sut.bulkWrite {
            try self.sut.replace(with: bulkItems)
        }

        let lateItem = MockCD_DTO(id: "late", name: "late")
        try await sut.addOrUpdate([lateItem])

        let found = try await sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Async write after bulkWrite was silently skipped")
    }

    func test_deleteSync_afterBulkWrite_persistsCorrectly() throws {
        let items = MockCD_DTO.mocks(count: 3)
        try sut.addOrUpdate(items)

        try sut.bulkWrite {
            try self.sut.addOrUpdate([MockCD_DTO(id: "bulk", name: "bulk")])
        }

        // Delete must save after a prior bulkWrite.
        try sut.delete([items[0].id])

        let found = try sut.getSingle(id: items[0].id)
        XCTAssertNil(found, "Delete after bulkWrite was silently skipped")
    }
}
