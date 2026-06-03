import Foundation

/// A plugin that detects maintenance mode responses and notifies the app on state changes.
///
/// When a response matches `statusCode` (default 503), the result is replaced with
/// `NetworkError.maintenance` and `onMaintenanceChange(true)` is called. When a
/// subsequent request succeeds, `onMaintenanceChange(false)` is called.
///
/// The callback fires only on transitions, not on every request.
public final class MaintenancePlugin: NetworkClientPlugin {

    public let maintenanceStatusCode: Int
    private let onMaintenanceChange: (Bool) -> Void
    private var isUnderMaintenance = false
    private let lock = NSLock()

    /// - Parameters:
    ///   - statusCode: The HTTP status code that indicates maintenance mode. Defaults to 503.
    ///   - onMaintenanceChange: Called when maintenance state changes. Receives `true` when
    ///     maintenance begins, `false` when it ends. Not dispatched to any specific queue —
    ///     dispatch to main yourself if driving UI.
    public init(
        statusCode: Int = 503,
        onMaintenanceChange: @escaping (Bool) -> Void
    ) {
        self.maintenanceStatusCode = statusCode
        self.onMaintenanceChange = onMaintenanceChange
    }

    public func process(
        _ result: Result<NetworkResponse, Error>,
        config: DevRequestConfig
    ) -> Result<NetworkResponse, Error> {
        let isMaintenance = isMaintenanceResponse(result)

        lock.lock()
        let stateChanged = isMaintenance != isUnderMaintenance
        if stateChanged { isUnderMaintenance = isMaintenance }
        lock.unlock()

        if stateChanged { onMaintenanceChange(isMaintenance) }

        return isMaintenance ? .failure(NetworkError.maintenance) : result
    }

    private func isMaintenanceResponse(_ result: Result<NetworkResponse, Error>) -> Bool {
        guard case .success(let output) = result,
              let http = output.response as? HTTPURLResponse else { return false }
        return http.statusCode == maintenanceStatusCode
    }
}
