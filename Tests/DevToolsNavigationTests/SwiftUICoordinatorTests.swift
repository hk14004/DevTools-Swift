//
//  SwiftUICoordinatorTests.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import XCTest
import SwiftUI
@testable import DevToolsNavigation

// MARK: - Example coordinator and router protocol
//
// In a real app these live in their respective feature modules.
// Shown here to demonstrate the two levels of testing:
//
//   1. Coordinator tests  — verify path mutations directly (path.count, isEmpty)
//   2. ViewModel tests    — verify navigation intent via a mock router protocol
//
// NavigationPath is opaque: you cannot inspect what types are on the stack,
// only how many items are there (path.count) and whether it is empty.
// Test the INTENT of navigation in ViewModel tests using mock routers;
// test the MECHANICS (push/pop/replace) in coordinator tests via path.count.

// MARK: Router protocol (defined by the feature, injected into the ViewModel)

protocol HomeRouter {
    func routeToProduct(id: String)
    func routeToSettings()
}

// MARK: Route enum

enum HomeRoute: Hashable {
    case productDetail(id: String)
    case settings
}

// MARK: Concrete coordinator

@Observable
class HomeCoordinator: SwiftUICoordinator, HomeRouter {
    var path = NavigationPath()

    func routeToProduct(id: String) { push(HomeRoute.productDetail(id: id)) }
    func routeToSettings()          { push(HomeRoute.settings) }
}

// MARK: Example ViewModel that holds a router protocol (not the coordinator directly)

class HomeViewModel {
    let router: HomeRouter

    init(router: HomeRouter) {
        self.router = router
    }

    func didTapProduct(id: String) { router.routeToProduct(id: id) }
    func didTapSettings()          { router.routeToSettings() }
}

// MARK: - Coordinator tests (path mechanics)

final class SwiftUICoordinatorTests: XCTestCase {

    private var sut: HomeCoordinator!

    override func setUp() {
        super.setUp()
        sut = HomeCoordinator()
    }

    func testInitialPathIsEmpty() {
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertEqual(sut.path.count, 0)
    }

    func testPushIncreasesPathCount() {
        sut.push(HomeRoute.settings)
        XCTAssertEqual(sut.path.count, 1)
    }

    func testMultiplePushesIncrementCount() {
        sut.push(HomeRoute.settings)
        sut.push(HomeRoute.productDetail(id: "1"))
        sut.push(HomeRoute.productDetail(id: "2"))
        XCTAssertEqual(sut.path.count, 3)
    }

    func testPopDecreasesPathCount() {
        sut.push(HomeRoute.settings)
        sut.push(HomeRoute.productDetail(id: "1"))
        sut.pop()
        XCTAssertEqual(sut.path.count, 1)
    }

    func testPopOnEmptyPathDoesNotCrash() {
        XCTAssertTrue(sut.path.isEmpty)
        sut.pop() // should be a no-op, not a crash
        XCTAssertTrue(sut.path.isEmpty)
    }

    func testPopToRootClearsAllItems() {
        sut.push(HomeRoute.settings)
        sut.push(HomeRoute.productDetail(id: "1"))
        sut.push(HomeRoute.productDetail(id: "2"))
        sut.popToRoot()
        XCTAssertTrue(sut.path.isEmpty)
    }

    func testReplaceTopKeepsSameCount() {
        sut.push(HomeRoute.settings)
        sut.push(HomeRoute.productDetail(id: "1"))
        let countBefore = sut.path.count
        sut.replaceTop(with: HomeRoute.productDetail(id: "99"))
        XCTAssertEqual(sut.path.count, countBefore)
    }

    func testReplaceTopOnEmptyPathPushesItem() {
        XCTAssertTrue(sut.path.isEmpty)
        sut.replaceTop(with: HomeRoute.settings)
        XCTAssertEqual(sut.path.count, 1)
    }

    func testSetStackReplacesAllItems() {
        sut.push(HomeRoute.settings)
        sut.push(HomeRoute.settings)
        sut.setStack([HomeRoute.productDetail(id: "1")])
        XCTAssertEqual(sut.path.count, 1)
    }

    func testSetStackWithEmptyArrayClearsPath() {
        sut.push(HomeRoute.settings)
        sut.setStack([HomeRoute]())
        XCTAssertTrue(sut.path.isEmpty)
    }
}

// MARK: - ViewModel tests (navigation intent via mock router)
//
// This is the preferred way to test navigation from a ViewModel.
// The ViewModel holds a router *protocol*, so a mock can be injected.
// You are testing WHAT the ViewModel asked to navigate to, not HOW
// the coordinator responded — keeping tests fast and UIKit/SwiftUI-free.

final class HomeViewModelNavigationTests: XCTestCase {

    private var mockRouter: MockHomeRouter!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockRouter = MockHomeRouter()
        sut = HomeViewModel(router: mockRouter)
    }

    func testDidTapProductRoutesToCorrectID() {
        sut.didTapProduct(id: "42")
        XCTAssertEqual(mockRouter.routedToProductID, "42")
    }

    func testDidTapSettingsRoutesToSettings() {
        sut.didTapSettings()
        XCTAssertTrue(mockRouter.routedToSettings)
    }

    func testTappingProductDoesNotTriggerSettings() {
        sut.didTapProduct(id: "1")
        XCTAssertFalse(mockRouter.routedToSettings)
    }
}

// MARK: - Mock router

private class MockHomeRouter: HomeRouter {
    private(set) var routedToProductID: String?
    private(set) var routedToSettings = false

    func routeToProduct(id: String) { routedToProductID = id }
    func routeToSettings()          { routedToSettings = true }
}
