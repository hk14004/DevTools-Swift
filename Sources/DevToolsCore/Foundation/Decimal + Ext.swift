//
//  Money.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

public typealias Money = Decimal

public extension Money {
    func asString() -> String {
        NumberFormatter.localizedString(from: self as NSDecimalNumber, number: .currency)
    }
    
    func discountPercentage(originalPrice: Money) -> Money {
        return (originalPrice - self) / originalPrice * 100
    }
    
    mutating func round(_ scale: Int = 2, _ roundingMode: NSDecimalNumber.RoundingMode = .down) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int = 2, _ roundingMode: NSDecimalNumber.RoundingMode = .down) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
