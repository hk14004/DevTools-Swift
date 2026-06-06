//
//  Publisher+AsResult.swift
//

import Combine

extension Publisher {

    /// Converts a failable publisher into an infallible stream of `Result` values.
    ///
    /// Instead of terminating the stream on the first failure, errors are wrapped
    /// in `.failure` and delivered as normal values. The publisher never fails,
    /// so a single error doesn't kill the subscription — subsequent values keep
    /// arriving.
    ///
    /// This is particularly useful in ViewModels that need to handle errors without
    /// tearing down the entire pipeline, and in UI bindings where the view should
    /// remain responsive after an error.
    ///
    /// ```swift
    /// // ViewModel
    /// networkClient.fetch()
    ///     .asResult()
    ///     .sink { [weak self] result in
    ///         switch result {
    ///         case .success(let data):  self?.items = data
    ///         case .failure(let error): self?.errorMessage = error.localizedDescription
    ///         }
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    public func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
