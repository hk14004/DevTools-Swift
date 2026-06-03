import OSLog

/// A plugin that logs requests and responses using OSLog.
///
/// Add this plugin to see full request/response details in the console.
/// Because `willSend` fires after all `prepare` hooks, the logged request
/// reflects the final state — including any headers injected by `AuthPlugin`.
public final class LoggingPlugin: NetworkClientPlugin {

    public init() {}

    public func willSend(_ request: URLRequest, config: DevRequestConfig) {
        Logger.logRequest(request)
    }

    public func didReceive(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) {
        switch result {
        case .success(let output):
            Logger.logResponse(output)
        case .failure(let error):
            Logger.logNoResponse(error: error)
        }
    }
}
