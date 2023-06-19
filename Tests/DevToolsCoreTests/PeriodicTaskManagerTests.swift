//
//  PeriodicTaskManagerTests.swift
//  
//
//  Created by Hardijs Ķirsis on 14/04/2023.
//

import XCTest
import DevToolsCore

final class PeriodicTaskManagerTests: XCTestCase {

    func testInternalTimerTask() throws {
        // Given
        let workExp = XCTestExpectation(description: "Work")
        workExp.expectedFulfillmentCount = 2
        
        // When
        /// Creating a periodic task that is timer fired
        let task = InternalTimerPeriodicTask(taskType: .refreshUserData, expectation: workExp)
        
        // Then
        wait(for: [workExp], timeout: 0.1)
    }
    
    func testNotificationTriggeredTask() throws {
        // Given
        let workExp = XCTestExpectation(description: "Work")
        workExp.expectedFulfillmentCount = 1
        
        // When
        /// Creating a periodic task that is notification triggered
        let taskType = TestPeriodicTaskType.refreshGuestData
        let task = NotificationTriggeredPeriodicTask(taskType: taskType, expectation: workExp)
        NotificationCenter.default.post(name: NSNotification.Name(taskType.getTaskID()), object: nil, userInfo: nil)
        
        // Then
        wait(for: [workExp], timeout: 0.1)
    }

}

fileprivate enum TestPeriodicTaskType: String, PeriodTaskType {
    case refreshUserData
    case refreshGuestData
}

fileprivate class InternalTimerPeriodicTask: PeriodicTaskBase<TestPeriodicTaskType> {
    
    init(taskType: TestPeriodicTaskType, expectation: XCTestExpectation) {
        self.expectedWork = expectation
        super.init(taskType: taskType)
    }
    
    private var timer: Timer!
    private var expectedWork: XCTestExpectation
    
    override func registerTrigger() {
        self.timer = .init(timeInterval: 0.01, target: self, selector: #selector(runWorkFlow), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    @objc override open func work() async {
        expectedWork.fulfill()
    }
    
    deinit {
        timer.invalidate()
    }
}

fileprivate class NotificationTriggeredPeriodicTask: PeriodicTaskBase<TestPeriodicTaskType> {
    
    init(taskType: TestPeriodicTaskType, expectation: XCTestExpectation) {
        self.expectedWork = expectation
        super.init(taskType: taskType)
    }
    
    
    private var expectedWork: XCTestExpectation
    
    override func registerTrigger() {}
    
    @objc override open func work() async {
        expectedWork.fulfill()
    }
}
