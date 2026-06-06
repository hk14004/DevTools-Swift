//
//  PeriodicTaskManagerTests.swift
//

import XCTest
import DevToolsCore

final class PeriodicTaskManagerTests: XCTestCase {

    // MARK: - Helpers

    private struct MockTask: PeriodicTask {
        let id: String
        let interval: TimeInterval
        let body: @Sendable () async throws -> Void
        func perform() async throws { try await body() }
    }

    // MARK: - Execution

    func testRunsImmediatelyOnSchedule() async {
        let ran = expectation(description: "ran")
        let manager = PeriodicTaskManager()
        await manager.schedule(MockTask(id: "t", interval: 60) { ran.fulfill() })
        await fulfillment(of: [ran], timeout: defaultTimeout)
        await manager.cancelAll()
    }

    func testRepeatsAfterInterval() async {
        let ran = expectation(description: "ran twice")
        ran.expectedFulfillmentCount = 2
        let manager = PeriodicTaskManager()
        await manager.schedule(MockTask(id: "t", interval: 0.05) { ran.fulfill() })
        await fulfillment(of: [ran], timeout: defaultTimeout)
        await manager.cancelAll()
    }

    // MARK: - Cancellation

    func testCancelPreventsRepeat() async {
        // Long interval — runs once immediately, cancel before it can repeat.
        // assertForOverFulfill (default true) fails the test if it runs again.
        let ran = expectation(description: "ran once")
        let manager = PeriodicTaskManager()
        await manager.schedule(MockTask(id: "t", interval: 60) { ran.fulfill() })
        await fulfillment(of: [ran], timeout: defaultTimeout)
        await manager.cancel(id: "t")
        let ids = await manager.scheduledIDs
        XCTAssertTrue(ids.isEmpty)
    }

    func testReschedulingCancelsPrevious() async {
        let first  = expectation(description: "first task ran")
        let second = expectation(description: "second task ran")
        let manager = PeriodicTaskManager()

        await manager.schedule(MockTask(id: "t", interval: 60) { first.fulfill() })
        await fulfillment(of: [first], timeout: defaultTimeout)

        await manager.schedule(MockTask(id: "t", interval: 60) { second.fulfill() })
        await fulfillment(of: [second], timeout: defaultTimeout)

        let ids = await manager.scheduledIDs
        XCTAssertEqual(ids.count, 1)
        await manager.cancelAll()
    }

    func testCancelAllStopsAll() async {
        let ran1 = expectation(description: "t1 ran")
        let ran2 = expectation(description: "t2 ran")
        let manager = PeriodicTaskManager()
        await manager.schedule(MockTask(id: "t1", interval: 60) { ran1.fulfill() })
        await manager.schedule(MockTask(id: "t2", interval: 60) { ran2.fulfill() })
        await fulfillment(of: [ran1, ran2], timeout: defaultTimeout)
        await manager.cancelAll()
        let ids = await manager.scheduledIDs
        XCTAssertTrue(ids.isEmpty)
    }

    // MARK: - Error Handling

    func testErrorHandlerCalledOnThrow() async {
        let errored = expectation(description: "error handler invoked")
        let manager = PeriodicTaskManager { _, _ in errored.fulfill() }
        await manager.schedule(MockTask(id: "t", interval: 60) { throw URLError(.badURL) })
        await fulfillment(of: [errored], timeout: defaultTimeout)
        await manager.cancelAll()
    }

    func testTaskContinuesAfterError() async {
        let ran = expectation(description: "ran twice despite error")
        ran.expectedFulfillmentCount = 2
        let manager = PeriodicTaskManager(onError: { _, _ in })
        await manager.schedule(MockTask(id: "t", interval: 0.05) {
            ran.fulfill()
            throw URLError(.badURL)
        })
        await fulfillment(of: [ran], timeout: defaultTimeout)
        await manager.cancelAll()
    }

    // MARK: - Inspection

    func testScheduledIDsReflectsState() async {
        let manager = PeriodicTaskManager()
        await manager.schedule(MockTask(id: "a", interval: 60) {})
        await manager.schedule(MockTask(id: "b", interval: 60) {})
        let both = await manager.scheduledIDs
        XCTAssertEqual(Set(both), ["a", "b"])
        await manager.cancel(id: "a")
        let afterCancel = await manager.scheduledIDs
        XCTAssertEqual(afterCancel, ["b"])
        await manager.cancelAll()
        let afterCancelAll = await manager.scheduledIDs
        XCTAssertTrue(afterCancelAll.isEmpty)
    }
}
