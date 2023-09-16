import Foundation

public protocol DevNetworkResponse: Decodable {
    static var shouldIgnoreNotFoundError: Bool { get }
    init(_ data: Data, response: URLResponse) throws
}

extension DevNetworkResponse {
    public static var shouldIgnoreNotFoundError: Bool { false }
    
    public init(_ data: Data, response: URLResponse) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}
