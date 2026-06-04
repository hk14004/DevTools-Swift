//
//  DeepLinkRouter.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import Foundation

/// A registry that delegates incoming URLs to the feature handler registered for that URL prefix.
///
/// Each feature module creates its own `DeepLinkHandling` conformer and registers it with the router.
/// The router dispatches based on the first path segment of the URL.
///
/// # Setup (App target)
/// ```swift
/// let router = DeepLinkRouter()
/// router.register(prefix: "onboarding", handler: OnboardingDeepLinkHandler(coordinator: ...))
/// router.register(prefix: "product",    handler: ProductDeepLinkHandler(coordinator: ...))
/// ```
///
/// # SceneDelegate wiring
/// ```swift
/// // URL schemes:  myapp://product/42
/// func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
///     guard let url = contexts.first?.url else { return }
///     router.handle(url)
/// }
///
/// // Universal links:  https://yoursite.com/product/42
/// func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
///     guard let url = userActivity.webpageURL else { return }
///     router.handle(url)
/// }
/// ```
///
/// # Feature module (self-contained, no App target involvement)
/// ```swift
/// // FeatureProduct/ProductDeepLinkHandler.swift
/// public enum ProductRoute {
///     case detail(id: String)
///     case reviews(productId: String)
/// }
///
/// public class ProductDeepLinkHandler: DeepLinkHandling {
///     weak var coordinator: ProductCoordinator?
///
///     public func route(for url: URL) -> ProductRoute? {
///         guard let id = url.pathSegments[safe: 1] else { return nil }
///         switch url.pathSegments[safe: 2] {
///         case "reviews": return .reviews(productId: id)
///         default:        return .detail(id: id)
///         }
///     }
///
///     public func handle(route: ProductRoute) {
///         switch route {
///         case .detail(let id):       coordinator?.showDetail(id: id)
///         case .reviews(let id):      coordinator?.showReviews(productId: id)
///         }
///     }
/// }
/// ```
public final class DeepLinkRouter {

    // Type-erased wrapper so handlers with different Route types can be stored together.
    private struct AnyHandler {
        private let _handle: (URL) -> Bool
        init<H: DeepLinkHandling>(_ handler: H) {
            _handle = { url in handler.handle(url) }
        }
        func handle(_ url: URL) -> Bool { _handle(url) }
    }

    private var handlers: [String: AnyHandler] = [:]

    public init() {}

    /// Registers a handler for all URLs whose first path segment matches `prefix`.
    ///
    /// - Parameters:
    ///   - prefix: The first URL path segment this handler owns (e.g. `"product"`, `"onboarding"`).
    ///   - handler: The feature's `DeepLinkHandling` conformer. Registering a second handler
    ///     for the same prefix replaces the first.
    public func register<H: DeepLinkHandling>(prefix: String, handler: H) {
        handlers[prefix] = AnyHandler(handler)
    }

    /// Finds the handler registered for the URL's first path segment and forwards the URL to it.
    /// - Returns: `true` if a handler was found and handled the URL, `false` otherwise.
    @discardableResult
    public func handle(_ url: URL) -> Bool {
        guard let prefix = url.pathSegments.first,
              let handler = handlers[prefix] else { return false }
        return handler.handle(url)
    }
}
