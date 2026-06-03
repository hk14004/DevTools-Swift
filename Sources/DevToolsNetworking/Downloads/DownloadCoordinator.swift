import Combine
import Foundation

/// Bridges URLSessionDownloadDelegate callbacks to per-task Combine publishers.
/// One coordinator handles all concurrent downloads via a shared URLSession.
final class DownloadCoordinator: NSObject {

    private var session: URLSession!
    private var activeTasks: [Int: PassthroughSubject<DownloadEvent, Error>] = [:]
    private let lock = NSLock()
    /// Forwarded to for auth challenges (e.g. SSL pinning) so downloads
    /// use the same certificate validation as regular requests.
    private weak var authDelegate: URLSessionDelegate?

    init(configuration: URLSessionConfiguration, authDelegate: URLSessionDelegate? = nil) {
        self.authDelegate = authDelegate
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    deinit {
        // Breaks the URLSession → delegate retain cycle and cancels in-flight tasks.
        session.invalidateAndCancel()
    }

    func download(request: URLRequest) -> AnyPublisher<DownloadEvent, Error> {
        let subject = PassthroughSubject<DownloadEvent, Error>()
        let task = session.downloadTask(with: request)
        locked { activeTasks[task.taskIdentifier] = subject }
        task.resume()
        return subject.eraseToAnyPublisher()
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadCoordinator: URLSessionDownloadDelegate {

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let total: Int64? = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown
            ? nil
            : totalBytesExpectedToWrite
        subject(for: downloadTask)?.send(.progress(bytesReceived: totalBytesWritten, totalBytes: total))
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Validate HTTP status before treating the file as a success.
        if let http = downloadTask.response as? HTTPURLResponse,
           !(200..<300 ~= http.statusCode) {
            subject(for: downloadTask)?.send(completion: .failure(httpError(for: http.statusCode)))
            locked { activeTasks.removeValue(forKey: downloadTask.taskIdentifier) }
            return
        }

        // `location` is valid only within this method — copy it before returning.
        let stableURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        do {
            try FileManager.default.copyItem(at: location, to: stableURL)
            subject(for: downloadTask)?.send(.completed(fileURL: stableURL))
            subject(for: downloadTask)?.send(completion: .finished)
        } catch {
            subject(for: downloadTask)?.send(completion: .failure(error))
        }
        locked { activeTasks.removeValue(forKey: downloadTask.taskIdentifier) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        subject(for: task)?.send(completion: .failure(error))
        locked { activeTasks.removeValue(forKey: task.taskIdentifier) }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Forward to the app's delegate (e.g. SSL pinning) if one was provided.
        // Otherwise fall back to default system handling.
        if let authDelegate {
            authDelegate.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - Helpers

private extension DownloadCoordinator {
    func subject(for task: URLSessionTask) -> PassthroughSubject<DownloadEvent, Error>? {
        locked { activeTasks[task.taskIdentifier] }
    }

    @discardableResult
    func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    func httpError(for statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .resourceNotFound
        default:  return .unexpectedResponse
        }
    }
}
