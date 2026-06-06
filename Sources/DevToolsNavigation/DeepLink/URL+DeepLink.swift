//
//  URL+DeepLink.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import Foundation

public extension URL {

    /// The meaningful path segments of the URL.
    ///
    /// For custom URL schemes (`myapp://`), the host is treated as the first
    /// path segment because `URL` parses `myapp://product/42` as host=`product`,
    /// path=`/42` — so `pathComponents` alone misses the first segment.
    ///
    /// For `http`/`https` (universal links), the host is your domain and is excluded;
    /// only the path segments are returned.
    ///
    /// Examples:
    /// - `myapp://product/42/details` → `["product", "42", "details"]`
    /// - `myapp://settings`           → `["settings"]`
    /// - `https://example.com/product/42` → `["product", "42"]`
    var pathSegments: [String] {
        let isCustomScheme = scheme.map { $0 != "http" && $0 != "https" } ?? true
        var segments: [String] = []
        if isCustomScheme, let host = host, !host.isEmpty {
            segments.append(host)
        }
        segments += pathComponents.filter { $0 != "/" && !$0.isEmpty }
        return segments
    }

    /// Returns the value of a single query parameter by key.
    /// When a key appears more than once, the last value wins.
    ///
    /// For `myapp://feed?tab=popular`, `queryValue(for: "tab")` returns `"popular"`.
    func queryValue(for key: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .last { $0.name == key }?
            .value
    }

    /// All query parameters as a `[String: String]` dictionary.
    /// When a key appears more than once, the last value wins.
    var queryParameters: [String: String] {
        let items = URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems ?? []
        return items.reduce(into: [:]) { result, item in
            result[item.name] = item.value ?? ""
        }
    }
}
