//
//  URL + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public extension URL {

    /// Returns `true` if the URL's scheme matches any of the custom schemes
    /// declared under `LSApplicationQueriesSchemes` in `Info.plist`.
    func isCustomUrlScheme() -> Bool {
        guard let schemes = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] else {
            return false
        }
        let lowercased = absoluteString.lowercased()
        return schemes.contains { lowercased.hasPrefix($0 + ":") }
    }

    /// The base host — last two domain components, e.g. `"example.com"` from
    /// `"api.v2.example.com"`. Returns the full `host` for single-component hosts.
    var baseHost: String {
        guard var components = host?.components(separatedBy: "."),
              components.count >= 2 else {
            return host ?? ""
        }
        let ext  = components.removeLast()
        let base = components.removeLast()
        return base + "." + ext
    }

    /// Returns a new URL with the given query item appended.
    /// Returns `self` unchanged if the URL cannot be parsed into components.
    func appending(queryItem name: String, value: String?) -> URL {
        guard var components = URLComponents(string: absoluteString) else { return self }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: name, value: value))
        components.queryItems = items
        return components.url ?? self
    }
}
