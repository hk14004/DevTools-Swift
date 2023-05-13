//
//  WebViewCookieHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import WebKit

public protocol AuthorizedEntityProtocol {
    associatedtype T // May hold token and other related data
    var id: String { get }
    var authorizationData: T { get }
}

public protocol WebViewCookieHandler {
    associatedtype T = AuthorizedEntityProtocol
    func configure()
    func storeWebConfiguration(authorizedEntityID: String, configuration: WKWebViewConfiguration)
    func getStoredAuthorizedEntityWebConfiguration(authorizedEntityID: String) -> WKWebViewConfiguration?
    func createAuthorizationCookies(forEntity entity: T, url: URL) -> [HTTPCookie]
    func setAuthorizationCookies(forEntity entity: T, to configuration: WKWebViewConfiguration, url: URL, completion: @escaping ()->())
    func findCookies(inConfig config: WKWebViewConfiguration, cookieNames: [String], completion: @escaping ([HTTPCookie])->())
    func makeCookie(withName name: String, value: String, domain: String) -> HTTPCookie
    func clearCache(forEntity entity: T, completion: @escaping ()->())
}

// MARK: Default public implementations

extension WebViewCookieHandler {
    func setAuthorizationCookies(forEntity entity: T, to configuration: WKWebViewConfiguration, url: URL, completion: @escaping ()->()) {
        // Create cookies
        let cookies: [HTTPCookie] = createAuthorizationCookies(forEntity: entity, url: url)
        
        // Set cookies
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
    
    func findCookies(inConfig config: WKWebViewConfiguration, cookieNames: [String], completion: @escaping ([HTTPCookie])->())  {
        config.websiteDataStore.httpCookieStore.getAllCookies { activeCookies in
            let found = activeCookies.filter({cookieNames.contains($0.name)})
            completion(found)
        }
    }
    
    func makeCookie(withName name: String, value: String, domain: String) -> HTTPCookie {
        let cookie = HTTPCookie(properties: [
            .domain: domain,
            .path: "/",
            .name: name,
            .value: value,
            .secure: "FALSE",
            .expires: NSDate(timeIntervalSinceNow: 31556952) // 1 Year
        ])!
        return cookie
    }
    
    func clearCache(forEntity entity: T, completion: @escaping ()->()) where T: AuthorizedEntityProtocol {
        guard let config: WKWebViewConfiguration = getStoredAuthorizedEntityWebConfiguration(authorizedEntityID: entity.id) else  {
            completion()
            return
        }
        URLCache.shared.removeAllCachedResponses()
        clearDataStore(store: config.websiteDataStore, completion: completion)
        
        func clearDataStore(store: WKWebsiteDataStore, completion: @escaping ()->()) {
            let group = DispatchGroup()
            // Cookies
            group.enter()
            store.httpCookieStore.getAllCookies { cookies in
                print("Deleting Cookies: \(cookies.map({$0.name}))")
                cookies.forEach { cookie in
                    store.httpCookieStore.delete(cookie)
                }
                group.leave()
            }
            // All other stuff
            group.enter()
            let types = WKWebsiteDataStore.allWebsiteDataTypes()
            store.fetchDataRecords(ofTypes: types) { records in
                print("Deleting records: \(records)")
                records.forEach { record in
                    group.enter()
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                        group.leave()
                    })
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
