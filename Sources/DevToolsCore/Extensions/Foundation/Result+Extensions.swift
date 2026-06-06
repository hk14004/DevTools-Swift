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

// MARK: - Collection of Results

public extension Collection {

    /// Returns the success values from a collection of `Result`s, discarding failures.
    ///
    /// Useful after parallel or batch operations where some items may have
    /// failed and you want to work with whatever succeeded.
    ///
    /// ```swift
    /// let results: [Result<User, Error>] = await fetchAll(ids)
    /// let users  = results.successes()  // [User]
    /// let errors = results.failures()   // [Error]
    /// ```
    func successes<Success, Failure: Error>() -> [Success]
    where Element == Result<Success, Failure> {
        compactMap { try? $0.get() }
    }

    /// Returns the failure errors from a collection of `Result`s, discarding successes.
    func failures<Success, Failure: Error>() -> [Failure]
    where Element == Result<Success, Failure> {
        compactMap { result in
            guard case .failure(let error) = result else { return nil }
            return error
        }
    }
}
