import Combine
import Foundation

/// Manages `URLSessionWebSocketTask` instances and bridges their delegate callbacks
/// and receive loops to per-task `PassthroughSubject` publishers.
///
/// One coordinator handles all concurrent WebSocket connections through a shared `URLSession`.
/// This mirrors the pattern used by `DownloadCoordinator` and `UploadCoordinator`.
final class WebSocketCoordinator: NSObject {

    private var session: URLSession!
    private var subjects: [Int: PassthroughSubject<WebSocketEvent, Error>] = [:]
    private let lock = NSLock()

    /// Forwarded to for auth challenges (e.g. SSL pinning) so WebSocket connections
    /// use the same certificate validation as regular HTTP requests.
    private weak var authDelegate: URLSessionDelegate?

    init(configuration: URLSessionConfiguration, authDelegate: URLSessionDelegate? = nil) {
        self.authDelegate = authDelegate
        super.init()
        // The coordinator acts as the URLSession delegate so it receives both
        // URLSessionWebSocketDelegate events and auth challenge callbacks.
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Connect

    func connect(request: URLRequest) -> WebSocketConnection {
        let subject = PassthroughSubject<WebSocketEvent, Error>()
        let task = session.webSocketTask(with: request)

        locked { subjects[task.taskIdentifier] = subject }
        task.resume()

        // Start the async receive loop immediately.
        // Incoming messages are queued by URLSession until the handshake completes,
        // so there is no risk of receiving a message before the `.connected` event.
        receiveLoop(task: task, subject: subject)

        // Cancel the underlying task if the subscriber cancels the publisher.
        let events = subject
            .handleEvents(receiveCancel: { [weak self] in
                self?.locked { self?.subjects.removeValue(forKey: task.taskIdentifier) }
                task.cancel(with: .normalClosure, reason: nil)
            })
            .eraseToAnyPublisher()

        return WebSocketConnection(task: task, events: events)
    }

    // MARK: - Receive loop

    private func receiveLoop(
        task: URLSessionWebSocketTask,
        subject: PassthroughSubject<WebSocketEvent, Error>
    ) {
        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    subject.send(.message(.text(text)))
                case .data(let data):
                    subject.send(.message(.data(data)))
                @unknown default:
                    break
                }
                // Recurse to wait for the next frame.
                self?.receiveLoop(task: task, subject: subject)

            case .failure(let error):
                // A clean server-initiated close fires `didCloseWith` first, which
                // completes the subject. This failure then becomes a no-op because
                // PassthroughSubject silently drops sends/completions after finishing.
                //
                // For unexpected drops (network loss, server crash), propagate as failure.
                subject.send(completion: .failure(error))
                self?.locked { self?.subjects.removeValue(forKey: task.taskIdentifier) }
            }
        }
    }

    // MARK: - Helpers

    @discardableResult
    private func locked<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketCoordinator: URLSessionWebSocketDelegate {

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        locked { subjects[webSocketTask.taskIdentifier] }?.send(.connected)
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let subject = locked { subjects.removeValue(forKey: webSocketTask.taskIdentifier) }
        subject?.send(.disconnected(closeCode: closeCode, reason: reason))
        subject?.send(completion: .finished)
    }
}

// MARK: - URLSessionDelegate (auth challenges / SSL pinning)

extension WebSocketCoordinator: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let authDelegate {
            authDelegate.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
