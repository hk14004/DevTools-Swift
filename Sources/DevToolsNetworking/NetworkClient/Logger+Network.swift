//
//  Logger.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import OSLog

public extension Logger {
    static let network = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DevNetwork",
        category: "network"
    )
}
