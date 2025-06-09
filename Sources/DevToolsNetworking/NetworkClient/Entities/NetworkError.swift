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

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .apiErrorResponse(let apiError):
            return apiError.message
        case .reachability:
            return "No internet connection."
        case .unauthorized:
            return "Unauthorized access."
        case .unexpected(let message):
            return "Unexpected error: \(message)"
        case .forbidden:
            return "Forbidden request."
        case .unexpectedResponse:
            return "Unexpected server response."
        case .resourceNotFound:
            return "Resource not found."
        }
    }
}
