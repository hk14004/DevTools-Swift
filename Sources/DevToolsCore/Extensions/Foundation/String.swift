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
        let range = NSRange(startIndex..., in: self)
        return String._emailRegex.firstMatch(in: self, options: [], range: range) != nil
    }

    // Compiled once at type initialisation — try! is safe for a hardcoded pattern.
    private static let _emailRegex: NSRegularExpression = try! NSRegularExpression(
        pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
        options: .caseInsensitive
    )
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

    /// Returns the string with only its first character uppercased.
    ///
    /// Unlike `.capitalized`, which uppercases every word, this only touches
    /// the first character — preserving the casing of the rest.
    ///
    /// ```swift
    /// "hello world".capitalizingFirstLetter()  // "Hello world"
    /// "hello world".capitalized                // "Hello World" ← often wrong
    /// "iPhone settings".capitalizingFirstLetter() // "IPhone settings" ← edge case
    /// ```
    func capitalizingFirstLetter() -> String {
        guard let first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
