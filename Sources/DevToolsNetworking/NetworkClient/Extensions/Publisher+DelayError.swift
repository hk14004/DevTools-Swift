//
//  Publisher+DelayError.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 31/07/2025.
//

import Combine

public extension Publisher {
  /// On errors matching `shouldDelay`, waits for `trigger` to emit (once) before failing.
  /// All other errors (or after the trigger) are sent immediately.
  ///
  /// - Parameters:
  ///   - shouldDelay: a closure that returns true for errors you want to delay.
  ///   - trigger:    a publisher whose first emission “unlocks” the delayed error.
  /// - Returns: a publisher that delays specified errors until after `trigger` fires.
  func delay<Trigger: Publisher>(
    whenError shouldDelay: @escaping (Failure) -> Bool,
    until trigger: Trigger
  ) -> AnyPublisher<Output, Failure>
  where Trigger.Failure == Never
  {
    return self.catch { error -> AnyPublisher<Output, Failure> in
      guard shouldDelay(error) else {
        // non‑matching errors pass through immediately
        return Fail(error: error).eraseToAnyPublisher()
      }
      // matching error → wait for trigger, then emit that error
      return trigger
        .first()
        .flatMap { _ in Fail<Output, Failure>(error: error) }
        .eraseToAnyPublisher()
    }
    .eraseToAnyPublisher()
  }
}
