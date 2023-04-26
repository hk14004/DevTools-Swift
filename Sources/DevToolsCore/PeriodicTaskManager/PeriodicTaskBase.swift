//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import Foundation
import Combine

open class PeriodicTaskBase<TaskType: PeriodTaskTypeProtocol> {
    
    // MARK: Properties
    
    public let taskType: TaskType
    @Published public var performingWork: Bool
    
    // MARK: Init
    
    public init(taskType: TaskType) {
        self.taskType = taskType
        performingWork = false
        NotificationCenter.default.addObserver(self, selector: #selector(runWorkFlow),
                                               name: Notification.Name(taskType.getTaskID()), object: nil)
        registerTrigger()
    }
    
    // MARK: Methods
    
    open func registerTrigger() {
        // Register some kind of timer if needed or something else
        fatalError("Implement")
    }
    
    open func work() async {
        // Actual "work" to be done
        fatalError("Implement")
    }
    
    @objc open func runWorkFlow() {
        Task {
            onAfterWork()
            await work()
            onAfterWork()
        }
    }
    
    open func onBeforeWork() {
        performingWork = true
    }
    
    open func onAfterWork() {
        performingWork = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(taskType.getTaskID()),
                                                  object: nil)
    }
}
