//
//  UIKitRouter+SwiftUI.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import SwiftUI
import UIKit

/// UIKit → SwiftUI migration bridge.
///
/// These helpers let a UIKit router push or present SwiftUI views directly,
/// without manually creating `UIHostingController` at every call site.
/// Use this when migrating an app screen by screen from UIKit to SwiftUI.
///
/// Example — pushing a new SwiftUI screen from a UIKit router:
/// ```swift
/// func routeToProfile(user: User) {
///     push(ProfileView(user: user))
/// }
/// ```
///
/// Example — presenting a SwiftUI sheet from a UIKit router:
/// ```swift
/// func routeToSettings() {
///     present(SettingsView())
/// }
/// ```
public extension UIKitRouter {

    /// Wraps `view` in a `UIHostingController` and pushes it onto the navigation stack.
    func push<V: View>(_ view: V, animated: Bool = true) {
        push(UIHostingController(rootView: view), animated: animated)
    }

    /// Wraps `view` in a `UIHostingController` and presents it modally.
    func present<V: View>(_ view: V, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(UIHostingController(rootView: view), animated: animated, completion: completion)
    }
}
