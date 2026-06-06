//
//  Calendar+UTC.swift
//

import Foundation

public extension Calendar {

    /// A Gregorian calendar fixed to UTC — no time zone offset, no DST shifts.
    ///
    /// Use this instead of `Calendar.current` whenever you are doing date
    /// arithmetic on server-sent timestamps (which are typically UTC), or
    /// any logic where the result must be the same regardless of the user's
    /// device time zone:
    ///
    /// ```swift
    /// // Display — device time zone is correct
    /// date.startOfDay()
    ///
    /// // Business logic — UTC is correct
    /// date.startOfDay(calendar: .utc)
    /// expiryDate.days(from: .now, calendar: .utc)
    /// ```
    static let utc: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()
}
