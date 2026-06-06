import Combine
import Foundation

/// Schedules downloads and uploads that continue even when the app is suspended or killed.
///
/// ## Setup — do this once at app startup
///
/// ```swift
/// // AppDelegate or your DI container:
/// let backgroundTransfers = BackgroundTransferManager(
///     sessionIdentifier: "com.myapp.background-transfers",  // stable across launches
///     requestFactory: myRequestFactory,
///     plugins: [AuthPlugin(headerProvider: myAuthProvider)]
/// )
/// backgroundTransfers.delegate = myTransferCoordinator
/// ```
///
/// ## Wire up AppDelegate
///
/// ```swift
/// func application(
///     _ application: UIApplication,
///     handleEventsForBackgroundURLSession identifier: String,
///     completionHandler: @escaping () -> Void
/// ) {
///     backgroundTransfers.handleEventsForBackgroundSession(completionHandler: completionHandler)
/// }
/// ```
///
/// ## Schedule a transfer
///
/// ```swift
/// backgroundTransfers.scheduleDownload(statementConfig)
///     .sink { completion in ... } receiveValue: { taskDescription in
///         // Store taskDescription to match against delegate callbacks
///     }
///     .store(in: &cancelBag)
/// ```
///
/// ## On relaunch
///
/// iOS relaunches the app and calls `handleEventsForBackgroundURLSession`. Recreate
/// `BackgroundTransferManager` with the **same** `sessionIdentifier` — the session
/// reconnects to in-progress transfers automatically. Your delegate will receive the
/// completion callbacks.
public final class BackgroundTransferManager: NSObject {

    // MARK: - Public

    public weak var delegate: BackgroundTransferManagerDelegate?

    // MARK: - Private

    private var session: URLSession!
    private let requestFactory: DevNetworkRequestFactory
    private let plugins: [any NetworkClientPlugin]
    private var backgroundCompletionHandler: (() -> Void)?
    private let lock = NSLock()

    // MARK: - Init

    /// - Parameters:
    ///   - sessionIdentifier: A stable, unique string used to reconnect to in-progress
    ///     transfers after a relaunch. Use something like `"\(Bundle.main.bundleIdentifier!).bg-transfers"`.
    ///   - requestFactory: Builds `URLRequest` objects from configs.
    ///   - plugins: Applied to every scheduled request — include `AuthPlugin` here
    ///     so background requests carry valid auth headers.
    public init(
        sessionIdentifier: String,
        requestFactory: DevNetworkRequestFactory,
        plugins: [any NetworkClientPlugin] = []
    ) {
        self.requestFactory = requestFactory
        self.plugins = plugins
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        config.sessionSendsLaunchEvents = true
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - App delegate integration

    /// Call this from `application(_:handleEventsForBackgroundURLSession:completionHandler:)`.
    /// The manager stores the handler and calls it once all queued events have been delivered.
    public func handleEventsForBackgroundSession(completionHandler: @escaping () -> Void) {
        locked { backgroundCompletionHandler = completionHandler }
    }

    // MARK: - Scheduling

    /// Prepares and schedules a background download.
    ///
    /// - Returns: A publisher that emits a `taskDescription` string identifying this transfer.
    ///   Store it to match against `BackgroundTransferManagerDelegate` callbacks.
    @discardableResult
    public func scheduleDownload(_ requestConfig: DevRequestConfig) -> AnyPublisher<String, Error> {
        prepareRequest(requestConfig)
            .map { [weak self] request -> String in
                guard let self else { return "" }
                let taskDescription = UUID().uuidString
                let task = self.session.downloadTask(with: request)
                task.taskDescription = taskDescription
                task.resume()
                return taskDescription
            }
            .eraseToAnyPublisher()
    }

    /// Prepares and schedules a background upload.
    ///
    /// Note: background sessions do not guarantee delivery of the server's response body
    /// after an app relaunch. Use `uploadDidFinish` as a signal that the bytes were sent
    /// successfully, then query the server separately if you need the response.
    ///
    /// - Returns: A publisher that emits a `taskDescription` string identifying this transfer.
    @discardableResult
    public func scheduleUpload(
        _ requestConfig: DevRequestConfig,
        source: UploadSource
    ) -> AnyPublisher<String, Error> {
        prepareRequest(requestConfig)
            .map { [weak self] request -> String in
                guard let self else { return "" }
                let taskDescription = UUID().uuidString
                let task: URLSessionUploadTask
                switch source {
                case .data(let data):   task = self.session.uploadTask(with: request, from: data)
                case .file(let url):    task = self.session.uploadTask(with: request, fromFile: url)
                }
                task.taskDescription = taskDescription
                task.resume()
                return taskDescription
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - URLSessionDownloadDelegate

extension BackgroundTransferManager: URLSessionDownloadDelegate {

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let description = downloadTask.taskDescription else { return }
        let progress: Double? = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown
            ? nil
            : Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        delegate?.backgroundTransferManager(self, task: description, didUpdateProgress: progress)
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let description = downloadTask.taskDescription else { return }

        // Validate HTTP status.
        if let http = downloadTask.response as? HTTPURLResponse,
           !(200..<300 ~= http.statusCode) {
            delegate?.backgroundTransferManager(
                self, task: description,
                didFailWith: httpError(for: http.statusCode)
            )
            return
        }

        // Copy the temp file before this method returns — the OS deletes the original immediately after.
        let stableURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        do {
            try FileManager.default.copyItem(at: location, to: stableURL)
            delegate?.backgroundTransferManager(self, downloadDidFinish: description, fileURL: stableURL)
        } catch {
            delegate?.backgroundTransferManager(self, task: description, didFailWith: error)
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension BackgroundTransferManager: URLSessionTaskDelegate {

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard let description = task.taskDescription else { return }
        let progress: Double? = totalBytesExpectedToSend == NSURLSessionTransferSizeUnknown
            ? nil
            : Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        delegate?.backgroundTransferManager(self, task: description, didUpdateProgress: progress)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let description = task.taskDescription else { return }

        if let error {
            delegate?.backgroundTransferManager(self, task: description, didFailWith: error)
            return
        }

        // Upload tasks signal completion here (no separate didFinishDownloading equivalent).
        if task is URLSessionUploadTask {
            delegate?.backgroundTransferManager(self, uploadDidFinish: description)
        }
        // Download tasks are handled in didFinishDownloadingTo — nothing to do here on success.
    }
}

// MARK: - URLSessionDelegate

extension BackgroundTransferManager: URLSessionDelegate {

    /// Called by the OS after all background events for this session have been delivered.
    /// Calling the stored completion handler tells iOS the app is done processing and
    /// the system can update the UI snapshot.
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let handler = locked { () -> (() -> Void)? in
            let h = backgroundCompletionHandler
            backgroundCompletionHandler = nil
            return h
        }
        DispatchQueue.main.async { handler?() }
    }
}

// MARK: - Private helpers

private extension BackgroundTransferManager {

    func prepareRequest(_ requestConfig: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        let base: URLRequest
        do {
            base = try requestFactory.urlRequest(requestConfig: requestConfig)
        } catch {
            return .fail(error)
        }
        return plugins.reduce(.just(base)) { chain, plugin in
            chain.flatMap { plugin.prepare($0, config: requestConfig) }.eraseToAnyPublisher()
        }
    }

    func httpError(for statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .resourceNotFound
        default:  return .unexpectedResponse
        }
    }

    @discardableResult
    func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
