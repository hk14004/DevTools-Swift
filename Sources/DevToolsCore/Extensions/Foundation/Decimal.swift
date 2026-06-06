//
//  Money.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

public typealias Money = Decimal

public extension Money {

    /// Formats the value as a currency string.
    ///
    /// Pass an explicit `currencyCode` (e.g. `"USD"`, `"EUR"`) to override the
    /// device locale. Omit it to use the locale default.
    ///
    /// `NumberFormatter` is expensive to allocate — formatters are cached by
    /// currency code so repeated calls don't pay the allocation cost each time.
    func asString(currencyCode: String = "") -> String {
        Money.formatter(currencyCode: currencyCode)
            .string(from: self as NSDecimalNumber) ?? ""
    }

    // MARK: - Private

    private static var cachedFormatters: [String: NumberFormatter] = [:]

    private static func formatter(currencyCode: String) -> NumberFormatter {
        if let cached = cachedFormatters[currencyCode] { return cached }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if !currencyCode.isEmpty { formatter.currencyCode = currencyCode }
        cachedFormatters[currencyCode] = formatter
        return formatter
    }
    
    func discountPercentage(originalPrice: Money) -> Money {
        return (originalPrice - self) / originalPrice * 100
    }
    
    mutating func round(_ scale: Int = 2, _ roundingMode: NSDecimalNumber.RoundingMode = .plain) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int = 2, _ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
