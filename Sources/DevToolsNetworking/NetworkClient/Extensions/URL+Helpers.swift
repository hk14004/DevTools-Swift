import Foundation

public extension URL {

    /// Creates a URL by combining a base URL string, a path, and optional query items.
    ///
    /// The base and path are joined safely — a trailing slash on `base` and a
    /// leading slash on `path` are normalised so the join never produces `//`.
    ///
    /// The `+` character in query values is percent-encoded as `%2B` to work around
    /// a known discrepancy between `URLComponents` and `NSURLComponents`:
    /// http://www.openradar.me/40751862
    ///
    /// Returns `nil` when:
    /// - `base` cannot be parsed by `URLComponents`
    /// - The parsed scheme is explicitly empty (e.g. `"://bad url"`)
    /// - The resulting URL cannot be assembled
    init?(base: String, path: String, queryItems: [URLQueryItem]? = nil) {
        guard var components = URLComponents(string: base) else { return nil }

        // Require a non-empty scheme so that a blank base URL ("") or a
        // scheme-less string doesn't silently produce a relative URL.
        // URLComponents accepts "" successfully with scheme == nil, which would
        // otherwise pass through and produce a URL from an empty string.
        guard let scheme = components.scheme, !scheme.isEmpty else { return nil }

        // Append path without introducing a double slash at the join.
        let trimmedBase = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        let normalPath  = path.hasPrefix("/") ? path : "/\(path)"
        components.path = trimmedBase + normalPath

        components.queryItems = queryItems

        // Percent-encode "+" in query strings. URLComponents leaves "+" as-is in
        // percentEncodedQuery, but servers typically decode "+" as a space.
        // Encoding it as "%2B" ensures literal plus signs are transmitted correctly.
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        guard let url = components.url else { return nil }
        self = url
    }
}
