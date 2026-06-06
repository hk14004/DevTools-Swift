//
//  TimeInterval+Ext.swift
//

import Foundation

/// Convenience constructors for `TimeInterval` (aka `Double` seconds).
///
/// Makes durations readable at call sites for `Timer`, `URLRequest.timeoutInterval`,
/// `DispatchQueue.asyncAfter`, and `UIView.animate`:
///
/// ```swift
/// Timer.scheduledTimer(withTimeInterval: .minutes(5), repeats: true) { _ in sync() }
/// URLSession.shared.configuration.timeoutIntervalForRequest = .seconds(30)
/// DispatchQueue.main.asyncAfter(deadline: .now() + .hours(1)) { refresh() }
/// UIView.animate(withDuration: .milliseconds(300)) { view.alpha = 0 }
/// ```
public extension TimeInterval {
    static func milliseconds(_ ms: Double) -> TimeInterval { ms / 1_000 }
    static func seconds(_ s: Double) -> TimeInterval { s }
    static func minutes(_ m: Double) -> TimeInterval { m * 60 }
    static func hours(_ h: Double) -> TimeInterval { h * 3_600 }
    static func days(_ d: Double) -> TimeInterval { d * 86_400 }
}
