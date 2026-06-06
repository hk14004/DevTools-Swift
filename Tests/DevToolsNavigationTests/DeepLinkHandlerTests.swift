//
//  DeepLinkHandlerTests.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import XCTest
import DevToolsCore
@testable import DevToolsNavigation

// MARK: - Example: how you'd define deep links for a real app

/// All deep link destinations in the app.
enum AppRoute: Equatable {
    case productDetail(id: String)
    case userProfile(username: String, tab: ProfileTab)
    case settings
    case webView(url: URL)
}

enum ProfileTab: String {
    case posts
    case followers
    // Fallback when an unrecognised tab value arrives in the URL.
    case unknown
}

/// Parses URLs of the form:
///   myapp://product/<id>
///   myapp://user/<username>?tab=posts
///   myapp://settings
///   myapp://webview?url=https%3A%2F%2Fexample.com%2Fterms
///
/// In a real app, `handle(route:)` would call into a coordinator or router
/// to perform the actual UIKit navigation.
class AppDeepLinkHandler: DeepLinkHandling {

    // Capture handled routes for test assertions.
    private(set) var handledRoute: AppRoute?

    func route(for url: URL) -> AppRoute? {
        let segments = url.pathSegments

        switch segments.first {
        case "product":
            guard let id = segments[safe: 1] else { return nil }
            return .productDetail(id: id)

        case "user":
            guard let username = segments[safe: 1] else { return nil }
            let tab = ProfileTab(rawValue: url.queryValue(for: "tab") ?? "") ?? .unknown
            return .userProfile(username: username, tab: tab)

        case "settings":
            return .settings

        case "webview":
            guard let urlString = url.queryValue(for: "url"),
                  let destination = URL(string: urlString),
                  destination.scheme == "http" || destination.scheme == "https" else { return nil }
            return .webView(url: destination)

        default:
            return nil
        }
    }

    func handle(route: AppRoute) {
        handledRoute = route
        // In a real app:
        // coordinator.navigate(to: route)
    }
}

// MARK: - Tests

final class DeepLinkHandlerTests: XCTestCase {

    private var sut: AppDeepLinkHandler!

    override func setUp() {
        super.setUp()
        sut = AppDeepLinkHandler()
    }

    // MARK: - route(for:)

    func testProductDetailRoute() {
        let url = URL(string: "myapp://product/42")!
        XCTAssertEqual(sut.route(for: url), .productDetail(id: "42"))
    }

    func testProductDetailWithMissingIDReturnsNil() {
        let url = URL(string: "myapp://product")!
        XCTAssertNil(sut.route(for: url))
    }

    func testUserProfileRouteWithKnownTab() {
        let url = URL(string: "myapp://user/john_doe?tab=posts")!
        XCTAssertEqual(sut.route(for: url), .userProfile(username: "john_doe", tab: .posts))
    }

    func testUserProfileRouteWithUnknownTab() {
        let url = URL(string: "myapp://user/john_doe?tab=reels")!
        XCTAssertEqual(sut.route(for: url), .userProfile(username: "john_doe", tab: .unknown))
    }

    func testUserProfileRouteWithNoTab() {
        let url = URL(string: "myapp://user/jane")!
        XCTAssertEqual(sut.route(for: url), .userProfile(username: "jane", tab: .unknown))
    }

    func testSettingsRoute() {
        let url = URL(string: "myapp://settings")!
        XCTAssertEqual(sut.route(for: url), .settings)
    }

    func testWebViewRouteWithValidURL() {
        // The destination URL must be percent-encoded inside the query string.
        let url = URL(string: "myapp://webview?url=https%3A%2F%2Fexample.com%2Fterms")!
        XCTAssertEqual(sut.route(for: url), .webView(url: URL(string: "https://example.com/terms")!))
    }

    func testWebViewRouteMissingURLParamReturnsNil() {
        let url = URL(string: "myapp://webview")!
        XCTAssertNil(sut.route(for: url))
    }

    func testWebViewRouteInvalidURLParamReturnsNil() {
        let url = URL(string: "myapp://webview?url=not-a-valid-url")!
        XCTAssertNil(sut.route(for: url))
    }

    func testUnrecognisedPathReturnsNil() {
        let url = URL(string: "myapp://unknown/path")!
        XCTAssertNil(sut.route(for: url))
    }

    // MARK: - handle(_ url:)

    func testHandleReturnsTrueForRecognisedURL() {
        let url = URL(string: "myapp://settings")!
        XCTAssertTrue(sut.handle(url))
    }

    func testHandleReturnsFalseForUnrecognisedURL() {
        let url = URL(string: "myapp://unknown")!
        XCTAssertFalse(sut.handle(url))
    }

    func testHandleCallsHandleRouteForRecognisedURL() {
        let url = URL(string: "myapp://product/99")!
        sut.handle(url)
        XCTAssertEqual(sut.handledRoute, .productDetail(id: "99"))
    }

    func testHandleDoesNotSetRouteForUnrecognisedURL() {
        let url = URL(string: "myapp://unknown")!
        sut.handle(url)
        XCTAssertNil(sut.handledRoute)
    }
}

// MARK: - URL+DeepLink tests

final class URLDeepLinkExtensionTests: XCTestCase {

    func testPathSegmentsCustomSchemeIncludesHost() {
        let url = URL(string: "myapp://product/42/details")!
        XCTAssertEqual(url.pathSegments, ["product", "42", "details"])
    }

    func testPathSegmentsCustomSchemeHostOnly() {
        // "myapp://settings" — host is "settings", path is empty.
        let url = URL(string: "myapp://settings")!
        XCTAssertEqual(url.pathSegments, ["settings"])
    }

    func testPathSegmentsUniversalLinkExcludesHost() {
        // For https URLs the host is the domain and should be excluded.
        let url = URL(string: "https://example.com/product/42")!
        XCTAssertEqual(url.pathSegments, ["product", "42"])
    }

    func testQueryValueForKnownKey() {
        let url = URL(string: "myapp://feed?tab=popular&page=2")!
        XCTAssertEqual(url.queryValue(for: "tab"), "popular")
    }

    func testQueryValueForMissingKeyReturnsNil() {
        let url = URL(string: "myapp://feed?tab=popular")!
        XCTAssertNil(url.queryValue(for: "page"))
    }

    func testQueryParametersReturnsAllPairs() {
        let url = URL(string: "myapp://feed?tab=popular&page=2")!
        XCTAssertEqual(url.queryParameters, ["tab": "popular", "page": "2"])
    }

    func testQueryParametersIsEmptyWhenNoQuery() {
        let url = URL(string: "myapp://settings")!
        XCTAssertTrue(url.queryParameters.isEmpty)
    }

    func testPathSegmentsDecodesPercentEncoding() {
        // Percent-encoded characters should be decoded in the returned segments.
        let url = URL(string: "myapp://user/john%20doe")!
        XCTAssertEqual(url.pathSegments, ["user", "john doe"])
    }

    func testQueryValueDecodesPercentEncoding() {
        let url = URL(string: "myapp://search?q=hello%20world")!
        XCTAssertEqual(url.queryValue(for: "q"), "hello world")
    }

    func testDuplicateQueryKeyLastValueWins() {
        let url = URL(string: "myapp://feed?tab=popular&tab=latest")!
        XCTAssertEqual(url.queryValue(for: "tab"), "latest")
        XCTAssertEqual(url.queryParameters["tab"], "latest")
    }
}

