import Foundation

public protocol DevRequestConfig {
    var baseURL: String { get }
    var path: String { get }
    var method: DevHTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyParameters: Data? { get }
    var headers: [String: String]? { get }
    var requiresAuthorization: Bool { get }
    var timeoutInterval: TimeInterval { get }
}

public extension DevRequestConfig {
    var queryItems: [URLQueryItem]? { nil }
    var bodyParameters: Data? { nil }
    var headers: [String: String]? { nil }
    var timeoutInterval: TimeInterval { 60 }
}
