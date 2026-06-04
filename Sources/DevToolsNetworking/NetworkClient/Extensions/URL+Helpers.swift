import Foundation

public extension URL {
    init?(base: String, path: String, queryItems: [URLQueryItem]? = nil) {
        var urlComponents = URLComponents(string: "\(base)\(path)")

        // Reject URLs with a missing or empty scheme. URLComponents is lenient and
        // may successfully parse strings like "://bad url" on newer platforms —
        // an empty scheme is never a valid URL for networking purposes.
        guard !(urlComponents?.scheme ?? "").isEmpty else { return nil }

        urlComponents?.queryItems = queryItems

        // `NSURLComponents` and `URLComponents` handle "+" differently
        // http://www.openradar.me/40751862
        // A local copy is needed to avoid a Swift warning about overlapping accesses.
        let urlComponentsCopy = urlComponents
        urlComponents?.percentEncodedQuery = urlComponentsCopy?.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        guard let url = urlComponents?.url else { return nil }
        self = url
    }
}
