//
//  String + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

public extension String {
    func toDateFromISO8601() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
    
    func isNumeric() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func isEmailAddress() -> Bool {
        wholeMatch(of: /[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,64}/i) != nil
    }
    
}

public extension String {
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
