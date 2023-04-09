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
}
