//
//  SwiftDataStoreTests+WriteRegressions.swift
//  DevTools
//

import Foundation
import XCTest

extension SwiftDataStoreTests {

    /// Regression: individual writes inside a bulkWrite must not save (and fire observers) eagerly.
    /// Previously, performAddOrUpdate/Delete/Replace called attemptSave() unconditionally,
    /// so observers fired on each sub-operation rather than once at the end of the batch.
    func test_bulkWriteSync_observerFiresOnceNotPerSubOperation() throws {
        var fireCount = 0
        let cancel = sut.observeList().sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in fireCount += 1 }
        )
        defer { cancel.cancel() }

        // Initial emission from prepend(()).
        XCTAssertEqual(fireCount, 1)

        let items = MockSD_DTO.mocks(count: 3)
        try sut.bulkWrite {
            try self.sut.addOrUpdate([items[0]])
            try self.sut.addOrUpdate([items[1]])
            try self.sut.addOrUpdate([items[2]])
        }

        // Observer should fire exactly once more (the batch save), not three times.
        XCTAssertEqual(fireCount, 2, "Observer fired \(fireCount) times — expected 2 (initial + batch end)")
    }

    /// Regression: write after a bulkWrite must persist. Mirrors the CoreData regression test.
    func test_writeSync_afterBulkWrite_persistsCorrectly() throws {
        try sut.bulkWrite {
            try self.sut.addOrUpdate(MockSD_DTO.mocks(count: 3))
        }

        let lateItem = MockSD_DTO(id: "late", name: "late")
        try sut.addOrUpdate([lateItem])

        let found = try sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Write after bulkWrite was silently skipped")
    }

    func test_writeAsync_afterBulkWrite_persistsCorrectly() async throws {
        try await sut.bulkWrite {
            try self.sut.replace(with: MockSD_DTO.mocks(count: 3))
        }

        let lateItem = MockSD_DTO(id: "late", name: "late")
        try await sut.addOrUpdate([lateItem])

        let found = try await sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Async write after bulkWrite was silently skipped")
    }
}
