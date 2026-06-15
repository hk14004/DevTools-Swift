//
//  WKWebView+ContentSize.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

public extension WKWebView {

    /// Returns the full scrollable content height of the loaded page in points.
    ///
    /// Reads `document.body.scrollHeight` via JavaScript, falling back to
    /// `document.documentElement.scrollHeight` if there is no body yet.
    ///
    /// Body height is used deliberately: `document.documentElement.scrollHeight`
    /// never reports less than the web view's own viewport height, so it cannot
    /// shrink when shorter content is loaded into a view that was previously taller.
    /// `document.body.scrollHeight` tracks the actual content and shrinks correctly.
    ///
    /// Call this after `webView(_:didFinish:)` fires to get an accurate measurement.
    /// For pages with late-loading content (lazy images, web fonts), measure again
    /// once that content has settled — `SelfSizingWebView` does this automatically
    /// via a `ResizeObserver`.
    ///
    /// ```swift
    /// func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    ///     Task {
    ///         let height = try await webView.contentHeight()
    ///         print("Content is \(height)pt tall")
    ///     }
    /// }
    /// ```
    func contentHeight() async throws -> CGFloat {
        let height: Double = try await evaluate(
            "(document.body ? document.body.scrollHeight : document.documentElement.scrollHeight)"
        )
        return CGFloat(height)
    }
}
