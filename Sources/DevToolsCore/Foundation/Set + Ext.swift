//
//  Set + Ext.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation

extension Set where Element: JSONMappedField {
    subscript(field: Element) -> Element? {
        get {
            return self.first { $0 == field }
        }
        set {
            if let newValue = newValue {
                update(with: newValue)
            } else {
                remove(field)
            }
        }
    }
}
