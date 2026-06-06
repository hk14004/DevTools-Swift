//
//  XCTestCase+Combine.swift
//
//
//  Created by Hardijs Ķirsis on 24/10/2023.
//

#if canImport(XCTest)
import Combine
import XCTest

// MARK: - Publisher awaiting

public extension XCTestCase {

    /// Waits for a publisher to emit a value or complete, returning the result or `nil` on timeout.
    ///
    /// Use this when you want to assert that a publisher **may or may not** emit —
    /// for example, testing that a publisher is **not** triggered under certain conditions.
    /// A `nil` return means the publisher timed out without emitting.
    ///
    /// For cases where a publisher **must** emit, use `awaitRequiredPublisher` instead,
    /// which calls `XCTFail` if the publisher times out.
    ///
    /// ```swift
    /// // Assert publisher was NOT called
    /// let result = awaitPublisher(viewModel.errorPublisher, timeout: 0.5)
    /// XCTAssertNil(result)
    ///
    /// // Assert publisher was called and check the value
    /// let result = awaitPublisher(viewModel.itemsPublisher)
    /// XCTAssertEqual(result?.value, expectedItems)
    /// ```
    @discardableResult
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Result<T.Output, Error>? {
        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Awaiting publisher — \(file):\(line)")
        expectation.isInverted = false

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        return result
    }

    /// Waits for a publisher to emit a value, failing the test loudly if it times out.
    ///
    /// Use this when a publisher **must** emit during a test. If the publisher does not
    /// emit within `timeout`, `XCTFail` is called with a clear message and the function
    /// returns `.failure(.timeout)` so subsequent assertions can still run.
    ///
    /// For cases where a publisher is **not** expected to emit, use `awaitPublisher` instead.
    ///
    /// ```swift
    /// let result = awaitRequiredPublisher(viewModel.itemsPublisher)
    /// XCTAssertEqual(result.value, expectedItems)
    /// ```
    @discardableResult
    func awaitRequiredPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Result<T.Output, Error> {
        guard let result = awaitPublisher(publisher, timeout: timeout, file: file, line: line) else {
            XCTFail(
                "Publisher timed out after \(timeout)s without emitting a value. " +
                "If you expect no emission, use awaitPublisher instead.",
                file: file, line: line
            )
            return .failure(PublisherTimeoutError.timedOut)
        }
        return result
    }
}

    /// Asserts that a publisher emits no value within the given timeout.
    ///
    /// Uses an inverted expectation — the test fails if the publisher emits anything.
    /// Prefer this over `awaitPublisher` + `XCTAssertNil` when the intent is
    /// explicitly "this should never fire".
    ///
    /// ```swift
    /// viewModel.triggerSomethingThatShouldNotCauseError()
    /// awaitPublisherSilence(viewModel.errorPublisher, timeout: 0.5)
    /// ```
    func awaitPublisherSilence<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Publisher should not emit — \(file):\(line)")
        expectation.isInverted = true

        let cancellable = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in expectation.fulfill() }
        )

        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
    }
}

// MARK: - Timeout error

/// Error returned by `awaitRequiredPublisher` when the publisher times out.
public enum PublisherTimeoutError: Error {
    case timedOut
}

// MARK: - collectNext

public extension Publisher where Failure == Never {

    /// Collects the next `count` values emitted after the current value and returns them as an array.
    ///
    /// The current value is dropped — only future emissions are collected.
    /// Useful for testing `@Published` properties or any non-failing publisher.
    ///
    /// ```swift
    /// let collected = viewModel.$items.collectNext(2)
    /// viewModel.loadPage(1)
    /// viewModel.loadPage(2)
    /// let result = awaitRequiredPublisher(collected)
    /// XCTAssertEqual(result.value?.count, 2)
    /// ```
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
#endif
