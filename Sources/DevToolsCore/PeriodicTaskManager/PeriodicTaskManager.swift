//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import Foundation

public protocol PeriodicTaskManagerProtocol {
    
    associatedtype TaskType: PeriodTaskTypeProtocol
    
    var registeredTasks: [String: PeriodicTaskBase<TaskType>] { get }
    
}

open class PeriodicTaskManager<T: PeriodTaskTypeProtocol>: PeriodicTaskManagerProtocol {
    
    public typealias TaskType = T
    public var registeredTasks: [String: PeriodicTaskBase<T>] = [:]
    
    public init() {}
    
    public func registerTask(task: PeriodicTaskBase<T>) {
        registeredTasks[task.taskType.getTaskID()] = task
    }
}
