//
//  SafariView.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import SafariServices
import SwiftUI

/// A SwiftUI view that presents a `SFSafariViewController` for in-app web browsing.
///
/// Use this when you want to keep the user inside the app instead of opening Safari.
/// It is the SwiftUI equivalent of `UIKitRouter.presentSafari(_:)`.
///
/// # Basic usage — inside a sheet
/// ```swift
/// .sheet(isPresented: $isShowingSafari) {
///     SafariView(url: URL(string: "https://example.com")!)
/// }
/// ```
///
/// # With the coordinator pattern
/// Add a `safariURL` property to your coordinator and use the `.safariSheet(url:)` modifier:
///
/// ```swift
/// @Observable
/// class HomeCoordinator: SwiftUICoordinator {
///     var path = NavigationPath()
///     var safariURL: URL?
///
///     func openInSafari(_ url: URL) { safariURL = url }
/// }
///
/// // In the view:
/// NavigationStack(path: $coordinator.path) {
///     HomeView()
/// }
/// .safariSheet(url: $coordinator.safariURL)
/// ```
public struct SafariView: UIViewControllerRepresentable {

    public let url: URL
    public var configuration: SFSafariViewController.Configuration

    public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
        self.url = url
        self.configuration = configuration
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url, configuration: configuration)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - View extension

public extension View {

    /// Presents a `SafariView` as a sheet when `url` is non-nil, and dismisses it by setting `url` back to nil.
    ///
    /// ```swift
    /// .safariSheet(url: $coordinator.safariURL)
    /// ```
    func safariSheet(url: Binding<URL?>) -> some View {
        sheet(isPresented: Binding(
            get: { url.wrappedValue != nil },
            set: { if !$0 { url.wrappedValue = nil } }
        )) {
            if let u = url.wrappedValue {
                SafariView(url: u)
            }
        }
    }
}
