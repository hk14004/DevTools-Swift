//
//  UIColor+Hex.swift
//

import UIKit

public extension UIColor {

    /// Creates a colour from a hex string.
    ///
    /// Accepts 6-digit (`RRGGBB`) and 8-digit (`RRGGBBAA`) hex strings,
    /// with or without a leading `#`.
    ///
    /// ```swift
    /// UIColor(hex: "#FF5500")      // opaque orange
    /// UIColor(hex: "FF5500")       // same, no hash
    /// UIColor(hex: "#FF550080")    // 50 % transparent orange
    /// UIColor(hex: "invalid")      // nil
    /// ```
    ///
    /// - Returns: `nil` if the string is not a valid 6- or 8-digit hex colour.
    convenience init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value) else { return nil }

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b, a) = ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, 0xFF)
        case 8:
            (r, g, b, a) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            return nil
        }

        self.init(
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
