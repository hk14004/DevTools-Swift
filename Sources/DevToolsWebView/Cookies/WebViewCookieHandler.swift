//
//  WebViewCookieHandler.swift
//  DevToolsWebView
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import WebKit
import DevToolsCore

/// Manages WKWebView cookies for authenticated sessions.
///
/// Conform to this protocol to handle cookie creation, injection, retrieval,
/// and cache clearing for a specific `AuthorizationCredentials` type.
///
/// # Minimal conformance
/// Implement `configure()`, `createAuthorizationCookies(forEntity:url:)`,
/// `storeWebConfiguration(authorizedEntityID:configuration:)`, and
/// `getStoredAuthorizedEntityWebConfiguration(authorizedEntityID:)`.
/// Everything else has a default implementation.
///
/// # Example
/// ```swift
/// class AppWebViewCookieHandler: WebViewCookieHandler {
///     typealias T = UserCredentials
///
///     private var configurations: [String: WKWebViewConfiguration] = [:]
///
///     func configure() {
///         // One-time setup if needed
///     }
///
///     func storeWebConfiguration(authorizedEntityID: String, configuration: WKWebViewConfiguration) {
///         configurations[authorizedEntityID] = configuration
///     }
///
///     func getStoredAuthorizedEntityWebConfiguration(authorizedEntityID: String) -> WKWebViewConfiguration? {
///         configurations[authorizedEntityID]
///     }
///
///     func createAuthorizationCookies(forEntity entity: UserCredentials, url: URL) -> [HTTPCookie] {
///         [makeCookie(withName: "auth_token", value: entity.token, domain: url.host ?? "")]
///     }
/// }
/// ```
public protocol WebViewCookieHandler {
    associatedtype T: AuthorizationCredentials
    func configure()
    func storeWebConfiguration(authorizedEntityID: String, configuration: WKWebViewConfiguration)
    func getStoredAuthorizedEntityWebConfiguration(authorizedEntityID: String) -> WKWebViewConfiguration?
    func createAuthorizationCookies(forEntity entity: T, url: URL) -> [HTTPCookie]
    func setAuthorizationCookies(forEntity entity: T, to configuration: WKWebViewConfiguration, url: URL, completion: @escaping () -> Void)
    func findCookies(inConfig config: WKWebViewConfiguration, cookieNames: [String], completion: @escaping ([HTTPCookie]) -> Void)
    func makeCookie(withName name: String, value: String, domain: String) -> HTTPCookie
    func clearCache(forEntity entity: T, completion: @escaping () -> Void)
}

// MARK: - Default implementations

public extension WebViewCookieHandler {

    func setAuthorizationCookies(forEntity entity: T, to configuration: WKWebViewConfiguration, url: URL, completion: @escaping () -> Void) {
        let cookies = createAuthorizationCookies(forEntity: entity, url: url)
        let group = DispatchGroup()
        cookies.forEach { cookie in
            group.enter()
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }

    func findCookies(inConfig config: WKWebViewConfiguration, cookieNames: [String], completion: @escaping ([HTTPCookie]) -> Void) {
        config.websiteDataStore.httpCookieStore.getAllCookies { activeCookies in
            completion(activeCookies.filter { cookieNames.contains($0.name) })
        }
    }

    func makeCookie(withName name: String, value: String, domain: String) -> HTTPCookie {
        HTTPCookie(properties: [
            .domain:  domain,
            .path:    "/",
            .name:    name,
            .value:   value,
            .secure:  "FALSE",
            .expires: NSDate(timeIntervalSinceNow: 31_556_952) // 1 year
        ])!
    }

    func clearCache(forEntity entity: T, completion: @escaping () -> Void) {
        guard let config = getStoredAuthorizedEntityWebConfiguration(authorizedEntityID: entity.id) else {
            completion()
            return
        }
        URLCache.shared.removeAllCachedResponses()
        clearDataStore(store: config.websiteDataStore, completion: completion)
    }
}

// MARK: - Private helpers

private func clearDataStore(store: WKWebsiteDataStore, completion: @escaping () -> Void) {
    let group = DispatchGroup()

    group.enter()
    store.httpCookieStore.getAllCookies { cookies in
        cookies.forEach { store.httpCookieStore.delete($0) }
        group.leave()
    }

    group.enter()
    let types = WKWebsiteDataStore.allWebsiteDataTypes()
    store.fetchDataRecords(ofTypes: types) { records in
        records.forEach { record in
            group.enter()
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                group.leave()
            }
        }
        group.leave()
    }

    group.notify(queue: .main) {
        completion()
    }
}
