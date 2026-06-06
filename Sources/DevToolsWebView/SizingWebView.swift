//
//  SizingWebView.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import Combine
import SwiftUI
import WebKit

/// A SwiftUI view that expands to match its web content height, up to a maximum.
///
/// Wraps `SelfSizingWebView` and manages its own frame height via SwiftUI state.
/// No manual `.frame(height:)` needed — the view sizes itself automatically.
///
/// When content exceeds `maxHeight`, the view caps at `maxHeight` and the internal
/// WebView scrolls. When content fits, internal scrolling is disabled so the view
/// composes cleanly inside a SwiftUI `ScrollView`.
///
/// # Loading a URL
/// ```swift
/// SizingWebView(url: URL(string: "https://example.com")!, maxHeight: 500)
/// ```
///
/// # Loading local HTML
/// ```swift
/// SizingWebView(html: "<h1>Hello</h1><p>Some content</p>", maxHeight: 300)
/// ```
///
/// # Inside a ScrollView (full content height, no internal scroll)
/// ```swift
/// ScrollView {
///     VStack {
///         Text("Article")
///         SizingWebView(html: articleHTML, maxHeight: .infinity)
///     }
/// }
/// ```
///
/// # Reacting to content height
/// ```swift
/// SizingWebView(url: url, maxHeight: 300) { height in
///     print("Content is \(height)pt tall")
/// }
/// ```
public struct SizingWebView: UIViewRepresentable {

    // MARK: - Properties

    public let source: WebViewSource
    public var configuration: WKWebViewConfiguration
    public var maxHeight: CGFloat
    public var onContentHeightChanged: ((CGFloat) -> Void)?
    public var onLoadingProgressChanged: ((Double) -> Void)?
    public var onError: ((Error) -> Void)?

    // MARK: - Init

    /// Loads a remote URL.
    public init(
        url: URL,
        configuration: WKWebViewConfiguration = .init(),
        maxHeight: CGFloat = 400,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        onLoadingProgressChanged: ((Double) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.source = .url(url)
        self.configuration = configuration
        self.maxHeight = maxHeight
        self.onContentHeightChanged = onContentHeightChanged
        self.onLoadingProgressChanged = onLoadingProgressChanged
        self.onError = onError
    }

    /// Loads a local HTML string.
    public init(
        html: String,
        baseURL: URL? = nil,
        configuration: WKWebViewConfiguration = .init(),
        maxHeight: CGFloat = 400,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        onLoadingProgressChanged: ((Double) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.source = .html(html, baseURL: baseURL)
        self.configuration = configuration
        self.maxHeight = maxHeight
        self.onContentHeightChanged = onContentHeightChanged
        self.onLoadingProgressChanged = onLoadingProgressChanged
        self.onError = onError
    }

    // MARK: - UIViewRepresentable

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> SelfSizingWebView {
        let webView = SelfSizingWebView(configuration: configuration)
        webView.maxHeight = maxHeight
        configure(webView, context: context)
        context.coordinator.subscribe(to: webView, onProgressChanged: onLoadingProgressChanged)
        context.coordinator.lastSource = source
        webView.load(source)
        return webView
    }

    public func updateUIView(_ webView: SelfSizingWebView, context: Context) {
        webView.maxHeight = maxHeight
        configure(webView, context: context)
        if context.coordinator.lastSource != source {
            context.coordinator.lastSource = source
            webView.load(source)
        }
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: SelfSizingWebView, context: Context) -> CGSize? {
        let measuredHeight = uiView.measuredContentHeight
        guard measuredHeight > 0 else { return nil }
        let width = proposal.width ?? UIScreen.main.bounds.width
        let height = maxHeight == .infinity ? measuredHeight : min(measuredHeight, maxHeight)
        return CGSize(width: width, height: height)
    }

    // MARK: - Private

    private func configure(_ webView: SelfSizingWebView, context: Context) {
        webView.onContentHeightChanged = { height in
            context.coordinator.lastHeight = height
            onContentHeightChanged?(height)
        }
        context.coordinator.onLoadingProgressChanged = onLoadingProgressChanged
        webView.onError = onError
    }
}

// MARK: - Coordinator

public extension SizingWebView {
    final class Coordinator {
        var lastHeight: CGFloat = 0
        var lastSource: WebViewSource?
        var onLoadingProgressChanged: ((Double) -> Void)?
        private var progressCancellable: AnyCancellable?

        func subscribe(to webView: SelfSizingWebView, onProgressChanged: ((Double) -> Void)?) {
            progressCancellable = webView.loadingProgressPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] progress in
                    self?.onLoadingProgressChanged?(progress)
                }
        }
    }
}
