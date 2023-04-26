//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import Foundation
import Combine

public protocol PeriodTaskTypeProtocol: RawRepresentable, CaseIterable where RawValue == String {}

public extension PeriodTaskTypeProtocol  {
    func getTaskID() -> String {
        return "PERIODIC_TASK_" + self.rawValue.uppercased()
    }
}
