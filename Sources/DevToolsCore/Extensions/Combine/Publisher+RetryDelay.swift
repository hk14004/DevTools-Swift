//
//  Publisher+RetryDelay.swift
//

import Combine

extension Publisher {

    /// Retries a failed publisher up to `times` times, waiting `delay` between
    /// each attempt.
    ///
    /// The built-in `.retry(_:)` re-subscribes immediately, which is rarely what
    /// you want for network requests. This variant inserts a pause before each
    /// retry, allowing transient errors to resolve.
    ///
    /// ```swift
    /// networkClient.fetch(endpoint)
    ///     .retry(times: 3, delay: .seconds(2), scheduler: DispatchQueue.main)
    ///     .sink(receiveValue: handle(_:), completionError: handleError(_:))
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Parameters:
    ///   - times: Maximum number of retries. `0` means no retries (original
    ///     failure is propagated immediately).
    ///   - delay: Time to wait before each retry attempt.
    ///   - scheduler: Scheduler on which the delay is applied.
    public func retry<S: Scheduler>(
        times: Int,
        delay: S.SchedulerTimeType.Stride,
        scheduler: S
    ) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard times > 0 else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return Just(())
                .delay(for: delay, scheduler: scheduler)
                .flatMap { _ in self }
                .retry(times: times - 1, delay: delay, scheduler: scheduler)
        }
        .eraseToAnyPublisher()
    }
}
