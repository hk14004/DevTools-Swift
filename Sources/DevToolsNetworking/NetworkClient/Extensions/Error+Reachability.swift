import Foundation

extension Error {
    var isReachabilityError: Bool {
        switch self {
        case URLError.notConnectedToInternet,
            URLError.networkConnectionLost,
            URLError.dataNotAllowed,
            URLError.internationalRoamingOff,
            URLError.cannotConnectToHost,
            URLError.timedOut:
            return true
        default:
            return false
        }
    }
}
