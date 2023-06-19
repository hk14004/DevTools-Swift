//
//  Date + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Date {
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    func addingHours(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    func isInFuture() -> Bool {
        return self > Date()
    }
    func days(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: self))
        return components.day ?? 0
    }
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}
