//
//  WKWebView+JavaScript.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

// MARK: - Errors

public enum WKWebViewEvaluationError: Error {
    /// The JavaScript executed successfully but the result could not be cast to the expected type.
    case typeMismatch(expected: String, got: String)
}

// MARK: - Extensions

public extension WKWebView {

    /// Evaluates JavaScript and returns the result cast to the expected type.
    ///
    /// The return type is inferred from context, so in most cases no explicit
    /// type annotation is needed.
    ///
    /// ```swift
    /// let title: String = try await webView.evaluate("document.title")
    /// let scrollY: Double = try await webView.evaluate("window.scrollY")
    /// let count: Int = try await webView.evaluate("document.querySelectorAll('a').length")
    /// ```
    ///
    /// - Throws: `WKWebViewEvaluationError.typeMismatch` if the result cannot be
    ///   cast to `T`, or a `WKError` if the JavaScript itself throws.
    func evaluate<T>(_ javascript: String) async throws -> T {
        let result = try await evaluateJavaScript(javascript)
        guard let typed = result as? T else {
            throw WKWebViewEvaluationError.typeMismatch(
                expected: String(describing: T.self),
                got: String(describing: type(of: result))
            )
        }
        return typed
    }

    /// Evaluates JavaScript without caring about the return value.
    ///
    /// Use this for JavaScript that produces side effects rather than a value
    /// (e.g. scrolling, triggering events, setting DOM properties).
    ///
    /// ```swift
    /// try await webView.run("window.scrollTo(0, 0)")
    /// try await webView.run("document.getElementById('banner').remove()")
    /// ```
    func run(_ javascript: String) async throws {
        try await evaluateJavaScript(javascript)
    }
}
