//
//  DispatchQueue+Ext.swift
//

import Foundation

public extension DispatchQueue {

    /// Schedules `execute` to run on this queue after `delay` seconds.
    ///
    /// A concise alternative to `asyncAfter(deadline: .now() + delay)`.
    /// Pairs naturally with `TimeInterval` convenience constructors:
    ///
    /// ```swift
    /// DispatchQueue.main.after(.seconds(2)) { showBanner() }
    /// DispatchQueue.main.after(.milliseconds(300)) { animateIn() }
    /// backgroundQueue.after(.minutes(1)) { syncCache() }
    /// ```
    func after(_ delay: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
}
