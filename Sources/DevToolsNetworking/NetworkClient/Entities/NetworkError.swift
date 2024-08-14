import Foundation

public enum NetworkError: Error, Equatable {
    case apiErrorResponse(ApiErrorResponse)
    case reachability
    case unauthorized
    case unexpected(String)
    case forbidden
    case unexpectedResponse
    case resourceNotFound
}
