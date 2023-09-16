import Foundation

public struct EmptyResponse { }

extension EmptyResponse: DevNetworkResponse {
    public init(_ data: Data, response: URLResponse) throws {
        self.init()
    }
    
    func toVoid() { }
}
