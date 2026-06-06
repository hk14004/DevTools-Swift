//
//  Date + Ext.swift
//
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Date {

    // MARK: - Arithmetic

    /// Adds `days` calendar days to the date.
    ///
    /// - Parameter calendar: Defaults to `Calendar.current` (device time zone).
    ///   Pass `Calendar.utc` when working with server-sent UTC timestamps to
    ///   avoid off-by-one results near midnight or on DST boundaries.
    func addingDays(_ days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Adds `hours` to the date.
    ///
    /// - Warning: On DST transition days, adding 24 hours may produce 23 or 25
    ///   hours of elapsed wall-clock time with `Calendar.current`. Use
    ///   `Calendar.utc` if you need exactly N × 3600 seconds.
    func addingHours(_ hours: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    // MARK: - Day boundaries

    /// Returns midnight at the start of the day this date falls in.
    ///
    /// - Parameter calendar: Defaults to `Calendar.current` (device time zone).
    ///   Pass `Calendar.utc` to get UTC midnight — important when grouping
    ///   server-sent timestamps by day, otherwise items near midnight can land
    ///   on different days for users in different time zones.
    func startOfDay(calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    // MARK: - Comparisons

    /// Returns `true` if this date is after the current moment.
    func isInFuture() -> Bool {
        self > Date()
    }

    /// Returns the number of calendar days between `date` and `self`.
    ///
    /// Both dates are snapped to midnight before differencing, so the result
    /// is always a whole number of days.
    ///
    /// - Parameter calendar: Defaults to `Calendar.current` (device time zone).
    ///   Pass `Calendar.utc` for server-side logic (expiry, streaks, billing
    ///   cycles) — `Calendar.current` can shift the result by ±1 day near
    ///   midnight depending on the device's time zone.
    ///
    /// ```swift
    /// // ✅ Displaying "3 days ago" to the user
    /// event.days(from: .now)
    ///
    /// // ✅ Checking if a subscription has expired
    /// expiryDate.days(from: .now, calendar: .utc)
    /// ```
    func days(from date: Date, calendar: Calendar = .current) -> Int {
        calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: self)
        ).day ?? 0
    }

    // MARK: - Display helpers

    /// `true` if this date falls on today in the device's calendar.
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    /// `true` if this date falls on yesterday in the device's calendar.
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }

    /// `true` if this date falls on tomorrow in the device's calendar.
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }

    /// `true` if this date and `date` fall on the same calendar day.
    ///
    /// - Parameter calendar: Defaults to `Calendar.current`. Pass `Calendar.utc`
    ///   when comparing server-sent UTC timestamps.
    func isInSameDay(as date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }

    // MARK: - Formatting

    /// Returns an ISO 8601 string with full date, time, and timezone offset,
    /// e.g. `"2024-03-15T14:32:00Z"`. Pairs with `String.toDateFromISO8601()`.
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}
