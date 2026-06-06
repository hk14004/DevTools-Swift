//
//  XCTestCase+MemoryLeak.swift
//  DevToolsXCTest
//
//  Created by Hardijs on 04/06/2026.
//

#if canImport(XCTest)
import XCTest

public extension XCTestCase {

    /// Asserts that the given object is deallocated by the end of the test.
    ///
    /// Registers a `tearDownBlock` that checks whether the object was released.
    /// A non-nil object at teardown indicates a retain cycle or strong reference
    /// that outlived the test — a potential memory leak.
    ///
    /// Call this immediately after creating the system under test and its dependencies.
    ///
    /// ```swift
    /// func test_viewModel_doesNotLeak() {
    ///     var sut: HomeViewModel? = HomeViewModel(router: MockHomeRouter())
    ///     assertNoMemoryLeak(sut!)
    ///     sut = nil
    ///     // teardown checks sut was deallocated
    /// }
    /// ```
    ///
    /// A common pattern is to assert leaks on the SUT and all injected dependencies
    /// so any direction of retain cycle is caught:
    ///
    /// ```swift
    /// let router = MockHomeRouter()
    /// let sut = HomeViewModel(router: router)
    /// assertNoMemoryLeak(sut)
    /// assertNoMemoryLeak(router)
    /// ```
    func assertNoMemoryLeak(
        _ object: AnyObject,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(
                object,
                "Potential memory leak — expected object to be deallocated after test.",
                file: file,
                line: line
            )
        }
    }
}
#endif
