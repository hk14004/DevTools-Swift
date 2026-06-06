//
//  WebView.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import Combine
import SwiftUI
import WebKit

/// A SwiftUI view that displays a `WKWebView`.
///
/// Use this when you need a fully customisable in-app browser — custom headers,
/// cookie injection, JavaScript evaluation, or progress tracking.
/// For simple read-only browsing with no customisation, prefer `SafariView`
/// from `DevToolsNavigation` instead.
///
/// # Loading a URL
/// ```swift
/// WebView(url: URL(string: "https://example.com")!)
/// ```
///
/// # Loading local HTML
/// ```swift
/// WebView(html: "<h1>Hello</h1><p>World</p>")
///
/// // With a base URL so relative assets resolve from the app bundle:
/// WebView(html: htmlString, baseURL: Bundle.main.bundleURL)
/// ```
///
/// # With pre-configured cookies
/// ```swift
/// let config = WKWebViewConfiguration()
/// Task {
///     await config.websiteDataStore.httpCookieStore.setCookies(cookies)
/// }
/// WebView(url: url, configuration: config)
/// ```
///
/// # Evaluating JavaScript after page load
/// ```swift
/// WebView(url: url) { webView in
///     Task {
///         let title: String = try await webView.evaluate("document.title")
///         print("Page title:", title)
///     }
/// }
/// ```
public struct WebView: UIViewRepresentable {

    // MARK: - Properties

    public let source: WebViewSource
    public var configuration: WKWebViewConfiguration
    public var onNavigationFinished: ((WKWebView) -> Void)?
    public var onLoadingProgressChanged: ((Double) -> Void)?
    public var onError: ((Error) -> Void)?

    // MARK: - Init

    /// Loads a remote URL.
    public init(
        url: URL,
        configuration: WKWebViewConfiguration = .init(),
        onNavigationFinished: ((WKWebView) -> Void)? = nil,
        onLoadingProgressChanged: ((Double) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.source = .url(url)
        self.configuration = configuration
        self.onNavigationFinished = onNavigationFinished
        self.onLoadingProgressChanged = onLoadingProgressChanged
        self.onError = onError
    }

    /// Loads a local HTML string.
    public init(
        html: String,
        baseURL: URL? = nil,
        configuration: WKWebViewConfiguration = .init(),
        onNavigationFinished: ((WKWebView) -> Void)? = nil,
        onLoadingProgressChanged: ((Double) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.source = .html(html, baseURL: baseURL)
        self.configuration = configuration
        self.onNavigationFinished = onNavigationFinished
        self.onLoadingProgressChanged = onLoadingProgressChanged
        self.onError = onError
    }

    // MARK: - UIViewRepresentable

    public func makeCoordinator() -> Coordinator {
        Coordinator(onNavigationFinished: onNavigationFinished, onError: onError)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        context.coordinator.subscribe(to: webView, onProgressChanged: onLoadingProgressChanged)
        context.coordinator.lastSource = source
        webView.load(source)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onNavigationFinished = onNavigationFinished
        context.coordinator.onLoadingProgressChanged = onLoadingProgressChanged
        context.coordinator.onError = onError
        if context.coordinator.lastSource != source {
            context.coordinator.lastSource = source
            webView.load(source)
        }
    }
}

// MARK: - Coordinator

public extension WebView {

    final class Coordinator: NSObject, WKNavigationDelegate {

        var onNavigationFinished: ((WKWebView) -> Void)?
        var onLoadingProgressChanged: ((Double) -> Void)?
        var onError: ((Error) -> Void)?
        var lastSource: WebViewSource?

        private var progressCancellable: AnyCancellable?

        init(
            onNavigationFinished: ((WKWebView) -> Void)?,
            onError: ((Error) -> Void)?
        ) {
            self.onNavigationFinished = onNavigationFinished
            self.onError = onError
        }

        func subscribe(to webView: WKWebView, onProgressChanged: ((Double) -> Void)?) {
            progressCancellable = webView.loadingProgressPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] progress in
                    self?.onLoadingProgressChanged?(progress)
                }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onNavigationFinished?(webView)
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onError?(error)
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onError?(error)
        }
    }
}
