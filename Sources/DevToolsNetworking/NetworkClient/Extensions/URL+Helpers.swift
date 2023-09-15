import Foundation

extension URL {
    init(base: String, path: String, queryItems: [URLQueryItem]? = nil) {
        var urlComponents = URLComponents(string: "\(base)\(path)")
        urlComponents?.queryItems = queryItems
        
        // `NSURLComponents` and `URLComponents` handles "+" differently
        // http://www.openradar.me/40751862
        // a local var is needed to fix a swift warning about "overlapping accesses" caused by writing to the same property that's being read.
        let urlComponentsCopy = urlComponents
        urlComponents?.percentEncodedQuery = urlComponentsCopy?.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        guard let url = urlComponents?.url else {
            preconditionFailure("Invalid URL used to create URL instance")
        }
        self = url
    }
}
