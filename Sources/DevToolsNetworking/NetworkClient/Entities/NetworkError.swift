import Foundation

public enum NetworkError: Error {
    case apiErrorResponse(ApiErrorResponse)
    case reachability
    case unauthorized
    case unexpected(Error)
    case forbidden(ApiErrorResponse? = nil)
    case unexpectedResponse
    case resourceNotFound
}
