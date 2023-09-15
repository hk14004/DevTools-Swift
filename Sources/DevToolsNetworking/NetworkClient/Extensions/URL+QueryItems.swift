import Foundation

extension URL {
    public func appending(_ items: [URLQueryItem]) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        queryItems.append(contentsOf: items)
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            fatalError("Invalid query item")
        }
        return url
    }
    
    public func appending(_ item: URLQueryItem) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        queryItems.append(item)
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            fatalError("Invalid query item")
        }
        return url
    }
}
