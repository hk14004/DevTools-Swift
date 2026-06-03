import Combine
import Foundation
import DevToolsCore

public protocol DevNetworkClient: AnyObject {
    func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error>
}

open class BaseNetworkClient: DevNetworkClient {
    // MARK: - Variables
    public let dataProvider: DevNetworkDataProvider
    public let requestFactory: DevNetworkRequestFactory
    public let reachabilityNotifier: NetworkReachability
    public let plugins: [any NetworkClientPlugin]

    // MARK: - Init
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory,
        reachabilityNotifier: NetworkReachability,
        plugins: [any NetworkClientPlugin] = []
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
        self.reachabilityNotifier = reachabilityNotifier
        self.plugins = plugins
    }

    // MARK: - Execute
    open func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        guard reachabilityNotifier.isReachable else {
            return .fail(NetworkError.reachability)
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<T, Error> in
                guard let self else { return .empty() }
                self.plugins.forEach { $0.willSend(request, config: requestConfig) }
                return self.dataProvider.output(for: request)
                    .mapError { $0 as Error }
                    .map { Result<NetworkResponse, Error>.success($0) }
                    .catch { Just(Result<NetworkResponse, Error>.failure($0)) }
                    .setFailureType(to: Error.self)
                    .flatMap { [weak self] result -> AnyPublisher<NetworkResponse, Error> in
                        guard let self else { return .empty() }
                        self.plugins.forEach { $0.didReceive(result, config: requestConfig) }
                        let processed = self.plugins.reduce(result) { $1.process($0, config: requestConfig) }
                        switch processed {
                        case .success(let output): return .just(output)
                        case .failure(let error): return .fail(error)
                        }
                    }
                    .decode()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Download

    /// Downloads a file, emitting progress events followed by a `.completed(fileURL:)` event.
    ///
    /// Runs through the same `prepareRequest` pipeline as `execute` — auth headers and
    /// other plugins are applied. Only `prepare` and `willSend` plugin hooks fire;
    /// `didReceive` and `process` are not called since downloads stream rather than
    /// produce a single response.
    ///
    /// Requires the `dataProvider` to conform to `DevFileDownloadProvider`.
    /// `DefaultNetworkDataProvider` supports this out of the box.
    ///
    /// Example:
    /// ```swift
    /// client.download(config)
    ///     .sink { event in
    ///         switch event {
    ///         case .progress(let received, let total):
    ///             print("\(received) / \(total ?? 0) bytes")
    ///         case .completed(let url):
    ///             try? FileManager.default.moveItem(at: url, to: destinationURL)
    ///         }
    ///     }
    /// ```
    open func download(_ requestConfig: DevRequestConfig) -> AnyPublisher<DownloadEvent, Error> {
        guard reachabilityNotifier.isReachable else {
            return .fail(NetworkError.reachability)
        }
        guard let downloadProvider = dataProvider as? DevFileDownloadProvider else {
            return .fail(NetworkError.unexpected(
                "dataProvider does not support file downloads. Conform it to DevFileDownloadProvider."
            ))
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<DownloadEvent, Error> in
                guard let self else { return .empty() }
                self.plugins.forEach { $0.willSend(request, config: requestConfig) }
                return downloadProvider.download(for: request)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Upload

    /// Uploads data or a file, emitting progress events followed by a decoded `.response(T)`.
    ///
    /// Runs through the same `prepareRequest` pipeline as `execute` — auth headers and
    /// plugins are applied. Only `prepare` and `willSend` fire; `didReceive` and `process`
    /// are not called since the response arrives after the upload stream, not as a standalone response.
    ///
    /// Requires the `dataProvider` to conform to `DevFileUploadProvider`.
    /// `DefaultNetworkDataProvider` supports this out of the box.
    ///
    /// Example:
    /// ```swift
    /// client.upload(config, source: .file(photoURL))
    ///     .sink { event in
    ///         switch event {
    ///         case .progress(let sent, let total):
    ///             progressBar.progress = event.progressFraction ?? 0
    ///         case .response(let uploadedPhoto):
    ///             print("Uploaded: \(uploadedPhoto.id)")
    ///         }
    ///     }
    /// ```
    open func upload<T: Codable>(
        _ requestConfig: DevRequestConfig,
        source: UploadSource
    ) -> AnyPublisher<UploadEvent<T>, Error> {
        guard reachabilityNotifier.isReachable else {
            return .fail(NetworkError.reachability)
        }
        guard let uploadProvider = dataProvider as? DevFileUploadProvider else {
            return .fail(NetworkError.unexpected(
                "dataProvider does not support uploads. Conform it to DevFileUploadProvider."
            ))
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<UploadEvent<T>, Error> in
                guard let self else { return .empty() }
                self.plugins.forEach { $0.willSend(request, config: requestConfig) }
                return uploadProvider.upload(request: request, source: source)
                    .flatMap { event -> AnyPublisher<UploadEvent<T>, Error> in
                        switch event {
                        case .progress(let sent, let total):
                            return .just(.progress(bytesSent: sent, totalBytes: total))
                        case .completed(let data, let response):
                            return Self.decodeUploadResponse(data: data, response: response)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Request preparation
    private static func decodeUploadResponse<T: Codable>(
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<UploadEvent<T>, Error> {
        guard let http = response as? HTTPURLResponse else {
            return .fail(NetworkError.unexpectedResponse)
        }
        guard 200..<300 ~= http.statusCode else {
            let error: NetworkError
            switch http.statusCode {
            case 401: error = .unauthorized
            case 403: error = .forbidden
            case 404: error = .resourceNotFound
            default:  error = .unexpectedResponse
            }
            return .fail(error)
        }
        do {
            return .just(.response(try JSONDecoder().decode(T.self, from: data)))
        } catch {
            return .fail(NetworkError.unexpectedResponse)
        }
    }

    open func prepareRequest(requestConfig: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
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
}
