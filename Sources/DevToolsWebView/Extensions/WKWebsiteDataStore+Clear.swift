//
//  WKWebsiteDataStore+Clear.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

public extension WKWebsiteDataStore {

    /// Clears all website data — cookies, cache, local storage, IndexedDB, and more.
    ///
    /// Use this when logging a user out to ensure no session data persists in the WebView.
    ///
    /// ```swift
    /// await WKWebsiteDataStore.default().clearAll()
    /// // or for a specific configuration:
    /// await webView.configuration.websiteDataStore.clearAll()
    /// ```
    func clearAll() async {
        // Clear cookies
        await httpCookieStore.clearCookies()

        // Clear all other website data (cache, local storage, IndexedDB, etc.)
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let records: [WKWebsiteDataRecord] = await withCheckedContinuation { continuation in
            fetchDataRecords(ofTypes: types) { continuation.resume(returning: $0) }
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            removeData(ofTypes: types, for: records) { continuation.resume() }
        }
    }
}
