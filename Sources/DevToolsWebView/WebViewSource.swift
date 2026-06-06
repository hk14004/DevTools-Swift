//
//  WebViewSource.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

/// Describes what a WebView should load — either a remote URL or a local HTML string.
///
/// ```swift
/// // Remote URL
/// let source = WebViewSource.url(URL(string: "https://example.com")!)
///
/// // Local HTML string
/// let source = WebViewSource.html("<h1>Hello</h1><p>World</p>")
///
/// // HTML with a base URL so relative asset paths resolve correctly
/// let source = WebViewSource.html("<img src='image.png'>", baseURL: Bundle.main.bundleURL)
/// ```
public enum WebViewSource: Equatable {
    case url(URL)
    /// - Parameters:
    ///   - html: The HTML string to load.
    ///   - baseURL: Optional base URL used to resolve relative paths (e.g. local images, CSS).
    ///     Pass `Bundle.main.bundleURL` to resolve assets from the app bundle.
    case html(String, baseURL: URL? = nil)
}

// MARK: - WKWebView convenience

public extension WKWebView {

    /// Loads the given source — either a URL request or an HTML string.
    ///
    /// ```swift
    /// webView.load(.url(url))
    /// webView.load(.html("<h1>Hello</h1>"))
    /// webView.load(.html(template, baseURL: Bundle.main.bundleURL))
    /// ```
    func load(_ source: WebViewSource) {
        switch source {
        case .url(let url):
            load(URLRequest(url: url))
        case .html(let html, let baseURL):
            loadHTMLString(html, baseURL: baseURL)
        }
    }
}
