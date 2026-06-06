//
//  SwiftDataStoreTests+WriteBulk.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 12/06/2025.
//

import Foundation
import XCTest

extension SwiftDataStoreTests {

    func test_bulkWriteAsync_writeNothing() async throws {
        try await sut.bulkWrite {}
        let result = try await sut.getList()
        XCTAssertTrue(result.isEmpty)
    }

    func test_bulkWriteAsync_writesData() async throws {
        let generated = MockSD_DTO.mocks(count: 99)
        try await sut.bulkWrite {
            try await self.sut.replace(with: generated)
            try await self.sut.addOrUpdate([self.mockDTO])
        }
        let result = try await sut.getList()
        XCTAssertEqual(result.count, generated.count + 1)
    }
}
