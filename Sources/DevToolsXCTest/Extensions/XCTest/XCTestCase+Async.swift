//
//  XCTestCase+Async.swift
//  DevToolsXCTest
//
//  Created by Hardijs on 04/06/2026.
//

#if canImport(XCTest)
import XCTest

public extension XCTestCase {

    /// Asserts that an async expression throws the expected error.
    ///
    /// `XCTAssertThrowsError` does not support async closures — use this instead.
    ///
    /// ```swift
    /// await assertAsyncThrows(
    ///     try await sut.login(username: "", password: ""),
    ///     expectedError: LoginError.emptyCredentials
    /// )
    /// ```
    func assertAsyncThrows<E: Error & Equatable>(
        _ expression: @autoclosure () async throws -> Any,
        expectedError: E,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail(
                "Expected '\(expectedError)' to be thrown but no error was thrown.",
                file: file, line: line
            )
        } catch let error as E {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail(
                "Expected '\(expectedError)' but caught '\(error)' instead.",
                file: file, line: line
            )
        }
    }

    /// Asserts that an async expression completes without throwing, returning the result.
    ///
    /// `XCTAssertNoThrow` does not support async closures — use this instead.
    /// Returns the expression's value so you can assert on it directly.
    ///
    /// ```swift
    /// let items = await assertAsyncNoThrow(try await sut.fetchItems())
    /// XCTAssertEqual(items?.count, 3)
    /// ```
    @discardableResult
    func assertAsyncNoThrow<T>(
        _ expression: @autoclosure () async throws -> T,
        file: StaticString = #file,
        line: UInt = #line
    ) async -> T? {
        do {
            return try await expression()
        } catch {
            XCTFail(
                "Expected no error but caught '\(error)'.",
                file: file, line: line
            )
            return nil
        }
    }
}
#endif
