//
//  WKWebView+Snapshot.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import UIKit
import WebKit

// MARK: - Error

public enum WKWebViewSnapshotError: Error {
    /// `takeSnapshot` completed without returning an image or an error.
    case noImageReturned
}

// MARK: - Extension

public extension WKWebView {

    /// Captures the visible portion of the web view as a `UIImage`.
    ///
    /// Call this after `webView(_:didFinish:)` fires to ensure the page is fully rendered.
    ///
    /// ```swift
    /// // Basic snapshot
    /// let image = try await webView.snapshot()
    ///
    /// // Snapshot a specific rect at 2× scale
    /// let config = WKSnapshotConfiguration()
    /// config.rect = CGRect(x: 0, y: 0, width: 300, height: 200)
    /// config.snapshotWidth = 600
    /// let image = try await webView.snapshot(configuration: config)
    /// ```
    ///
    /// - Parameter configuration: Optional snapshot configuration. Pass `nil` to
    ///   capture the entire visible rect at the screen's native scale.
    /// - Returns: A `UIImage` of the rendered web content.
    /// - Throws: `WKWebViewSnapshotError.noImageReturned` if WebKit returns neither
    ///   an image nor an error, or a `WKError` if rendering fails.
    func snapshot(configuration: WKSnapshotConfiguration? = nil) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            takeSnapshot(with: configuration) { image, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: WKWebViewSnapshotError.noImageReturned)
                }
            }
        }
    }
}
