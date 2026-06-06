//
//  String + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

// MARK: - Parsing

public extension String {

    func toDateFromISO8601() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
}

// MARK: - Validation

public extension String {

    /// The string with leading and trailing whitespace and newlines removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `true` if the string is empty or contains only whitespace/newlines.
    var isBlank: Bool { trimmed.isEmpty }

    func isNumeric() -> Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    func isEmailAddress() -> Bool {
        wholeMatch(of: /[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,64}/i) != nil
    }
}

// MARK: - Transformation

public extension String {

    /// Returns the string truncated to `length` characters with `trailing` appended.
    ///
    /// ```swift
    /// "Hello, world!".truncated(to: 7)            // "Hello, ..."
    /// "Hello, world!".truncated(to: 7, trailing: "→") // "Hello, →"
    /// "Hi".truncated(to: 10)                       // "Hi"
    /// ```
    func truncated(to length: Int, trailing: String = "...") -> String {
        guard count > length else { return self }
        return String(prefix(length)) + trailing
    }

    /// The initials of the string — first character of each whitespace-separated
    /// word, uppercased and joined.
    ///
    /// ```swift
    /// "John Doe".initials          // "JD"
    /// "María José García".initials // "MJG"
    /// "alice".initials             // "A"
    /// ```
    var initials: String {
        split(separator: " ")
            .compactMap(\.first)
            .map { String($0).uppercased() }
            .joined()
    }

    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
