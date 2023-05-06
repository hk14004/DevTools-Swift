//
//  Money.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

public typealias Money = Decimal

public extension Money {
    func asString(currencyCode: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = currencyCode
        if currencyCode.isEmpty {
            return NumberFormatter.localizedString(from: self as NSDecimalNumber, number: .currency)
        } else {
            return formatter.string(from: self as NSDecimalNumber) ?? ""
        }
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
