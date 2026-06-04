//
//  DeepLinkHandler.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import Foundation

/// A protocol for handling deep links in a typed, testable way.
///
/// Conform to this protocol by:
/// 1. Defining a `Route` enum for your app's deep link destinations.
/// 2. Implementing `route(for:)` to parse a URL into a `Route`.
/// 3. Implementing `handle(route:)` to perform the actual navigation.
///
/// The default `handle(_ url:)` implementation wires parsing and navigation together,
/// returning `false` when the URL is not recognised.
///
/// Example:
/// ```swift
/// class AppDeepLinkHandler: DeepLinkHandling {
///     func route(for url: URL) -> AppRoute? { ... }
///     func handle(route: AppRoute) { ... }
/// }
///
/// // In SceneDelegate:
/// func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
///     guard let url = contexts.first?.url else { return }
///     deepLinkHandler.handle(url)
/// }
/// ```
public protocol DeepLinkHandling {
    associatedtype Route

    /// Parses a URL into a typed route. Return `nil` if the URL is not recognised.
    func route(for url: URL) -> Route?

    /// Performs navigation to the given route.
    func handle(route: Route)
}

public extension DeepLinkHandling {

    /// Parses `url` and, if recognised, navigates to the resulting route.
    /// - Returns: `true` if the URL was handled, `false` if it was not recognised.
    @discardableResult
    func handle(_ url: URL) -> Bool {
        guard let route = route(for: url) else { return false }
        handle(route: route)
        return true
    }
}
