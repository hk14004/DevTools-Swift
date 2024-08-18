//
//  URL + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

extension URL {
    func isCustomUrlScheme() -> Bool {
        let webUrlPrefixes: [String] = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as! [String]
        let urlStringLowerCase = absoluteString.lowercased()
        for (_, scheme) in webUrlPrefixes.enumerated() {
            if urlStringLowerCase.hasPrefix(scheme + ":") {
                return true
            }
        }
        return false
    }
    
    func getBaseHost() -> String {
        let components = host?.components(separatedBy: ".")
        guard var components = components, components.count >= 2 else {
            return host ?? ""
        }
        let ext = components.removeLast()
        let base = components.removeLast()
        let baseHost = base + "." + ext
        return baseHost
    }
    
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
    
    func addUtmParameter(property: String = "utm_source", value: String = "app") -> URL {
        return self.appending(property, value: value)
    }
}
