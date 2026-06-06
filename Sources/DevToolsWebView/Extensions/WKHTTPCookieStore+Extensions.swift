//
//  WKHTTPCookieStore+Extensions.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

public extension WKHTTPCookieStore {

    /// Injects all given cookies into the store concurrently.
    ///
    /// ```swift
    /// let cookies = [HTTPCookie.make(name: "auth_token", value: token, domain: "api.example.com")]
    ///     .compactMap { $0 }
    /// await webView.configuration.websiteDataStore.httpCookieStore.setCookies(cookies)
    /// ```
    func setCookies(_ cookies: [HTTPCookie]) async {
        await withTaskGroup(of: Void.self) { group in
            for cookie in cookies {
                group.addTask { await self.setCookie(cookie) }
            }
        }
    }

    /// Returns all cookies whose name matches one of the given names.
    ///
    /// ```swift
    /// let found = await cookieStore.findCookies(named: ["auth_token", "session_id"])
    /// ```
    func findCookies(named names: [String]) async -> [HTTPCookie] {
        let all = await allCookies()
        return all.filter { names.contains($0.name) }
    }

    /// Deletes all cookies in the store.
    ///
    /// ```swift
    /// await webView.configuration.websiteDataStore.httpCookieStore.clearCookies()
    /// ```
    func clearCookies() async {
        let cookies = await allCookies()
        await withTaskGroup(of: Void.self) { group in
            for cookie in cookies {
                group.addTask { await self.deleteCookie(cookie) }
            }
        }
    }
}
