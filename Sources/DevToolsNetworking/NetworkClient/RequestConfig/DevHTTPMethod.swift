import Foundation

public enum DevHTTPMethod: String, CaseIterable {
    case get
    case post
    case put
    case delete
    case patch = "PATCH"
}
