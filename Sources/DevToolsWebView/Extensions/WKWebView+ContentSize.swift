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
    /// Reads `document.documentElement.scrollHeight` via JavaScript.
    /// Call this after `webView(_:didFinish:)` fires to get an accurate measurement.
    /// For pages with late-loading content (lazy images, web fonts), you may need
    /// to call this again once that content has settled.
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
        let height: Double = try await evaluate("document.documentElement.scrollHeight")
        return CGFloat(height)
    }
}
