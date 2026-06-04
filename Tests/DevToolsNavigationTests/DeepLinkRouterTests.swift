//
//  DeepLinkRouterTests.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import XCTest
@testable import DevToolsNavigation

// MARK: - Simulated feature modules
//
// In a real app each of these would live inside its own framework target
// (e.g. FeatureOnboarding, FeatureProduct). They have zero knowledge of
// each other and zero knowledge of AppRoute — each module is self-contained.

// MARK: FeatureOnboarding

enum OnboardingRoute: Equatable {
    case start
    case step(index: Int)
}

// Handles:  myapp://onboarding
//           myapp://onboarding/step/2
class OnboardingDeepLinkHandler: DeepLinkHandling {
    private(set) var handledRoute: OnboardingRoute?

    func route(for url: URL) -> OnboardingRoute? {
        switch url.pathSegments[safe: 1] {
        case "step":
            guard let indexString = url.pathSegments[safe: 2],
                  let index = Int(indexString) else { return nil }
            return .step(index: index)
        default:
            return .start
        }
    }

    func handle(route: OnboardingRoute) {
        handledRoute = route
        // coordinator?.navigate(to: route)
    }
}

// MARK: FeatureProduct

enum ProductRoute: Equatable {
    case detail(id: String)
    case reviews(productId: String)
}

// Handles:  myapp://product/42
//           myapp://product/42/reviews
class ProductDeepLinkHandler: DeepLinkHandling {
    private(set) var handledRoute: ProductRoute?

    func route(for url: URL) -> ProductRoute? {
        guard let id = url.pathSegments[safe: 1] else { return nil }
        switch url.pathSegments[safe: 2] {
        case "reviews": return .reviews(productId: id)
        default:        return .detail(id: id)
        }
    }

    func handle(route: ProductRoute) {
        handledRoute = route
        // coordinator?.navigate(to: route)
    }
}

// MARK: - Tests

final class DeepLinkRouterTests: XCTestCase {

    private var sut: DeepLinkRouter!
    private var onboardingHandler: OnboardingDeepLinkHandler!
    private var productHandler: ProductDeepLinkHandler!

    override func setUp() {
        super.setUp()
        // App target wires up the router once at launch — each feature
        // registers its own handler for its URL prefix.
        onboardingHandler = OnboardingDeepLinkHandler()
        productHandler = ProductDeepLinkHandler()

        sut = DeepLinkRouter()
        sut.register(prefix: "onboarding", handler: onboardingHandler)
        sut.register(prefix: "product",    handler: productHandler)
    }

    // MARK: - Routing to the correct feature handler

    func testOnboardingStartRouteIsDispatched() {
        sut.handle(URL(string: "myapp://onboarding")!)
        XCTAssertEqual(onboardingHandler.handledRoute, .start)
        XCTAssertNil(productHandler.handledRoute)
    }

    func testOnboardingStepRouteIsDispatched() {
        sut.handle(URL(string: "myapp://onboarding/step/3")!)
        XCTAssertEqual(onboardingHandler.handledRoute, .step(index: 3))
        XCTAssertNil(productHandler.handledRoute)
    }

    func testProductDetailRouteIsDispatched() {
        sut.handle(URL(string: "myapp://product/42")!)
        XCTAssertEqual(productHandler.handledRoute, .detail(id: "42"))
        XCTAssertNil(onboardingHandler.handledRoute)
    }

    func testProductReviewsRouteIsDispatched() {
        sut.handle(URL(string: "myapp://product/42/reviews")!)
        XCTAssertEqual(productHandler.handledRoute, .reviews(productId: "42"))
        XCTAssertNil(onboardingHandler.handledRoute)
    }

    // MARK: - Unregistered prefix

    func testUnregisteredPrefixReturnsFalse() {
        XCTAssertFalse(sut.handle(URL(string: "myapp://settings")!))
    }

    func testUnregisteredPrefixDoesNotTriggerAnyHandler() {
        sut.handle(URL(string: "myapp://settings")!)
        XCTAssertNil(onboardingHandler.handledRoute)
        XCTAssertNil(productHandler.handledRoute)
    }

    // MARK: - Return values

    func testHandleReturnsTrueForRegisteredPrefix() {
        XCTAssertTrue(sut.handle(URL(string: "myapp://product/42")!))
    }

    func testHandleReturnsFalseWhenHandlerDoesNotRecogniseURL() {
        // "product" is registered but the handler returns nil for a missing ID.
        XCTAssertFalse(sut.handle(URL(string: "myapp://product")!))
    }

    // MARK: - Re-registration replaces previous handler

    func testRegisteringSecondHandlerForSamePrefixReplacesFirst() {
        let replacement = ProductDeepLinkHandler()
        sut.register(prefix: "product", handler: replacement)

        sut.handle(URL(string: "myapp://product/99")!)

        XCTAssertNil(productHandler.handledRoute, "Original handler should no longer receive URLs")
        XCTAssertEqual(replacement.handledRoute, .detail(id: "99"))
    }
}

// MARK: - Helpers

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
