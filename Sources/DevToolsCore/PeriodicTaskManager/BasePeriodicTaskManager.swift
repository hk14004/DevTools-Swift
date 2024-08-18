//
//  PeriodicTaskManager.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import Foundation

public protocol PeriodicTaskManager {
    
    associatedtype TaskType: PeriodTaskType
    
    var registeredTasks: [String: PeriodicTaskBase<TaskType>] { get }
    
}

open class BasePeriodicTaskManager<T: PeriodTaskType>: PeriodicTaskManager {
    
    public typealias TaskType = T
    public var registeredTasks: [String: PeriodicTaskBase<T>] = [:]
    
    public init() {}
    
    public func registerTask(task: PeriodicTaskBase<T>) {
        registeredTasks[task.taskType.getTaskID()] = task
    }
}
