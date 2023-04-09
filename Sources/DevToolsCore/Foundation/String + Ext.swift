//
//  String + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import Foundation

extension String {
    func isEmailAddress() -> Bool {
        // Regular expression to validate email addresses
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
