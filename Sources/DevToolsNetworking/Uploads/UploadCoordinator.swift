import Combine
import Foundation

/// Bridges URLSession upload delegate callbacks to per-task Combine publishers.
final class UploadCoordinator: NSObject {

    // MARK: - Task state

    private struct TaskState {
        let subject: PassthroughSubject<UploadProgressEvent, Error>
        var receivedData = Data()
        var response: URLResponse?
    }

    // MARK: - Properties

    private var session: URLSession!
    private var activeTasks: [Int: TaskState] = [:]
    private let lock = NSLock()
    private weak var authDelegate: URLSessionDelegate?

    // MARK: - Init

    init(configuration: URLSessionConfiguration, authDelegate: URLSessionDelegate? = nil) {
        self.authDelegate = authDelegate
        super.init()
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Upload

    func upload(request: URLRequest, source: UploadSource) -> AnyPublisher<UploadProgressEvent, Error> {
        let subject = PassthroughSubject<UploadProgressEvent, Error>()
        let task: URLSessionUploadTask

        switch source {
        case .data(let data):
            task = session.uploadTask(with: request, from: data)
        case .file(let url):
            task = session.uploadTask(with: request, fromFile: url)
        }

        locked { activeTasks[task.taskIdentifier] = TaskState(subject: subject) }
        task.resume()
        return subject.eraseToAnyPublisher()
    }
}

// MARK: - URLSessionTaskDelegate (progress + completion)

extension UploadCoordinator: URLSessionTaskDelegate {

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        locked { activeTasks[task.taskIdentifier] }?
            .subject.send(.progress(bytesSent: totalBytesSent, totalBytes: totalBytesExpectedToSend))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard var state = locked({ activeTasks.removeValue(forKey: task.taskIdentifier) }) else { return }

        if let error {
            state.subject.send(completion: .failure(error))
            return
        }
        guard let response = state.response else {
            state.subject.send(completion: .failure(NetworkError.unexpectedResponse))
            return
        }
        state.subject.send(.completed(data: state.receivedData, response: response))
        state.subject.send(completion: .finished)
    }
}

// MARK: - URLSessionDataDelegate (response body)

extension UploadCoordinator: URLSessionDataDelegate {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        locked { activeTasks[dataTask.taskIdentifier]?.response = response }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        locked { activeTasks[dataTask.taskIdentifier]?.receivedData.append(data) }
    }
}

// MARK: - URLSessionDelegate (auth challenges / SSL pinning)

extension UploadCoordinator: URLSessionDelegate {

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

// MARK: - Helpers

private extension UploadCoordinator {
    @discardableResult
    func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
