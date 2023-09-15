import Foundation

public struct ApiErrorResponse: Equatable, Decodable {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

// MARK: - NetworkResponse
extension ApiErrorResponse: NetworkResponse { }
