//
//  SwiftDataStoreTests+WriteRegressions.swift
//  DevTools
//

import Foundation
import XCTest

extension SwiftDataStoreTests {

    /// Regression: observer fires exactly once at the end of a bulk write, not per sub-operation.
    func test_bulkWriteAsync_observerFiresOnceNotPerSubOperation() async throws {
        var fireCount = 0
        let cancel = sut.observeList().sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in fireCount += 1 }
        )
        defer { cancel.cancel() }

        // Initial emission from prepend(()).
        XCTAssertEqual(fireCount, 1)

        let items = MockSD_DTO.mocks(count: 3)
        try await sut.bulkWrite {
            try await self.sut.addOrUpdate([items[0]])
            try await self.sut.addOrUpdate([items[1]])
            try await self.sut.addOrUpdate([items[2]])
        }

        // Observer should fire exactly once more (the batch save), not three times.
        XCTAssertEqual(fireCount, 2, "Observer fired \(fireCount) times — expected 2 (initial + batch end)")
    }

    /// Regression: write after a bulkWrite must persist.
    func test_writeAsync_afterBulkWrite_persistsCorrectly() async throws {
        try await sut.bulkWrite {
            try await self.sut.addOrUpdate(MockSD_DTO.mocks(count: 3))
        }

        let lateItem = MockSD_DTO(id: "late", name: "late")
        try await sut.addOrUpdate([lateItem])

        let found = try await sut.getSingle(id: lateItem.id)
        XCTAssertEqual(found?.id, lateItem.id, "Write after bulkWrite was silently skipped")
    }

    func test_writeAsync_afterBulkWrite_deletesPersistCorrectly() async throws {
        try await sut.bulkWrite {
            try await self.sut.replace(with: MockSD_DTO.mocks(count: 3))
        }

        let lateItem = MockSD_DTO(id: "late", name: "late")
        try await sut.addOrUpdate([lateItem])
        try await sut.delete([lateItem.id])

        let found = try await sut.getSingle(id: lateItem.id)
        XCTAssertNil(found, "Delete after bulkWrite was silently skipped")
    }
}
