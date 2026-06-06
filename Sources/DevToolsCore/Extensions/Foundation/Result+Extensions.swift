//
//  Result+Extensions.swift
//  DevToolsCore
//
//  Created by Hardijs on 04/06/2026.
//

import Foundation

public extension Result {

    /// Returns `true` if this result is a success.
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// Returns `true` if this result is a failure.
    var isFailure: Bool { !isSuccess }

    /// Returns the success value, or `nil` if this result is a failure.
    var value: Success? {
        if case .success(let value) = self { return value }
        return nil
    }

    /// Returns the failure error, or `nil` if this result is a success.
    var error: Failure? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
