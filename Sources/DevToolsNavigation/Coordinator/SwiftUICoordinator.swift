//
//  SwiftUICoordinator.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import SwiftUI

/// The SwiftUI equivalent of `UIKitRouter`.
///
/// Conform to this protocol in an `@Observable` class to get default push/pop
/// implementations for free. Each navigation stack in your app gets its own coordinator.
///
/// ---
///
/// # NavigationStack vs NavigationPath
///
/// These two are commonly confused but serve different roles:
///
/// - **`NavigationStack`** is the container — the visual chrome with the back button
///   and navigation bar. You place it in your view hierarchy once.
///   Think of it as the SwiftUI equivalent of `UINavigationController`.
///
/// - **`NavigationPath`** is the state — a list of what's currently on the stack.
///   Think of it as the equivalent of `navigationController.viewControllers`.
///   Modifying the path is how you navigate programmatically.
///
/// ```
/// UIKit                           SwiftUI
/// ──────────────────────────────────────────────
/// UINavigationController    →     NavigationStack
/// viewControllers array     →     NavigationPath
/// pushViewController        →     path.append(route)
/// popViewController         →     path.removeLast()
/// setViewControllers        →     path = NavigationPath(routes)
/// ```
///
/// ---
///
/// # Gotcha: never own NavigationPath directly in a view's @State
///
/// This is the most common SwiftUI navigation mistake. If `NavigationPath` lives
/// directly in a view's `@State`, SwiftUI can recreate that view and reset your
/// entire navigation stack silently.
///
/// ```swift
/// // ❌ Wrong — path lives in the view, can be reset by SwiftUI
/// struct RootView: View {
///     @State private var path = NavigationPath()
/// }
///
/// // ✅ Correct — path lives in a coordinator class, stable across view recreation
/// struct RootView: View {
///     @State private var coordinator = HomeCoordinator()
/// }
/// ```
///
/// The view holds a reference to the coordinator via `@State`, but the coordinator
/// is a class — SwiftUI preserves the instance, so the path survives.
///
/// ---
///
/// # Gotcha: register navigationDestination on the stack root, not on pushed views
///
/// `navigationDestination(for:)` must be attached to the root view inside
/// `NavigationStack`, not to individual pushed views. If you register it on a
/// pushed view, it may silently not work or produce unexpected behaviour.
///
/// ```swift
/// // ❌ Wrong — registered on a child/pushed view
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
/// }
/// // somewhere inside HomeView:
/// .navigationDestination(for: ProductRoute.self) { ... } // unreliable
///
/// // ✅ Correct — registered on the root view inside NavigationStack
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
///         .navigationDestination(for: ProductRoute.self) { ... }
///         .navigationDestination(for: ProfileRoute.self) { ... }
/// }
/// ```
///
/// ---
///
/// # Gotcha: sheets and full screen covers are separate from the stack
///
/// `NavigationPath` only controls the push/pop stack. Modals (sheets, full screen
/// covers) are driven by separate state on the coordinator. SwiftUI has no equivalent
/// of UIKit's `present(_:animated:)` — instead you declare the possible modals and
/// bind them to state.
///
/// ```swift
/// @Observable
/// class HomeCoordinator: SwiftUICoordinator {
///     var path = NavigationPath()
///
///     // Separate state for each modal type
///     var presentedSheet: HomeSheetRoute?     // drives .sheet(item:)
///     var presentedFullScreen: HomeRoute?     // drives .fullScreenCover(item:)
/// }
///
/// // In the view:
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
/// }
/// .sheet(item: $coordinator.presentedSheet) { route in ... }
/// .fullScreenCover(item: $coordinator.presentedFullScreen) { route in ... }
/// ```
///
/// ---
///
/// # Aha: NavigationPath can hold mixed route types on the same stack
///
/// Unlike a typed array (`[HomeRoute]`), `NavigationPath` is type-erased and can
/// hold any `Hashable` type. This means one stack can navigate across multiple
/// feature route enums — as long as each type has a `navigationDestination` registered.
///
/// ```swift
/// // One stack, routes from two different feature modules:
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
///         .navigationDestination(for: HomeRoute.self)    { ... }
///         .navigationDestination(for: ProductRoute.self) { ... }
/// }
///
/// // Push routes from either feature:
/// coordinator.push(HomeRoute.feed)
/// coordinator.push(ProductRoute.detail(id: "42"))
/// ```
///
/// The tradeoff: `NavigationPath` is opaque — you cannot inspect what types
/// are currently on the stack. If you need that, use a typed array instead,
/// but accept that it can only hold one route type.
///
/// ---
///
/// # Aha: path.isEmpty means you're at the root
///
/// `path.count` tells you how many screens are pushed on top of root.
/// `path.isEmpty` means the root view is showing. You never need to check
/// for a special "root" sentinel value — the absence of items IS the root.
///
/// ---
///
/// # One coordinator per NavigationStack — not one global coordinator
///
/// Each independent navigation stack in your app gets its own coordinator.
/// For a tab bar app this typically means one per tab:
///
/// ```swift
/// struct MainTabView: View {
///     @State private var homeCoordinator    = HomeCoordinator()
///     @State private var profileCoordinator = ProfileCoordinator()
///
///     var body: some View {
///         TabView {
///             NavigationStack(path: $homeCoordinator.path)    { ... }
///             NavigationStack(path: $profileCoordinator.path) { ... }
///         }
///     }
/// }
/// ```
///
/// ---
///
/// # ViewModels talk to a router protocol, not to the coordinator directly
///
/// Same pattern as UIKit — the ViewModel holds a router protocol so it stays
/// testable. The coordinator conforms to the protocol. The ViewModel never
/// imports or references the coordinator class itself.
///
/// ```swift
/// protocol HomeRouter {
///     func routeToProduct(id: String)
/// }
///
/// class HomeViewModel {
///     let router: HomeRouter  // protocol, not HomeCoordinator
///
///     func didTapProduct(id: String) {
///         router.routeToProduct(id: id)   // testable via mock
///     }
/// }
///
/// @Observable
/// class HomeCoordinator: SwiftUICoordinator, HomeRouter {
///     var path = NavigationPath()
///     func routeToProduct(id: String) { push(HomeRoute.productDetail(id: id)) }
/// }
/// ```
///
/// ---
///
/// # Defining a coordinator
///
/// ```swift
/// @Observable
/// class HomeCoordinator: SwiftUICoordinator, HomeRouter {
///     var path = NavigationPath()
///
///     @ViewBuilder
///     func view(for route: HomeRoute) -> some View {
///         switch route {
///         case .productDetail(let id): ProductDetailView(router: self, id: id)
///         case .reviews(let id):       ReviewsView(router: self, productId: id)
///         }
///     }
///
///     func routeToProduct(id: String)        { push(HomeRoute.productDetail(id: id)) }
///     func routeToReviews(productId: String) { push(HomeRoute.reviews(id: productId)) }
/// }
/// ```
///
/// # Wiring into a NavigationStack
///
/// ```swift
/// struct RootView: View {
///     @State private var coordinator = HomeCoordinator()
///
///     var body: some View {
///         NavigationStack(path: $coordinator.path) {
///             HomeView()
///                 .navigationDestination(for: HomeRoute.self) {
///                     coordinator.view(for: $0)
///                 }
///         }
///         .environment(coordinator)
///     }
/// }
/// ```
public protocol SwiftUICoordinator: AnyObject {
    var path: NavigationPath { get set }
}

public extension SwiftUICoordinator {

    /// Pushes a route onto the navigation stack.
    func push<R: Hashable>(_ route: R) {
        path.append(route)
    }

    /// Pops the top item off the navigation stack.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all items, returning to the root.
    func popToRoot() {
        path.removeLast(path.count)
    }

    /// Replaces the top item without leaving it in the back stack.
    /// Use this for redirect-style transitions (e.g. step 1 → step 2 in an onboarding flow).
    func replaceTop<R: Hashable>(with route: R) {
        guard !path.isEmpty else { push(route); return }
        path.removeLast()
        path.append(route)
    }

    /// Replaces the entire navigation stack.
    /// Use this where the back stack must be cleared entirely (e.g. login → home).
    func setStack<R: Hashable>(_ routes: [R]) {
        path = NavigationPath(routes)
    }

    /// Opens a URL via UIApplication (browser, phone, mailto, etc.).
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    /// Opens the app's own page in iOS Settings.
    /// Use this after a permission is denied to let the user enable it manually.
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
