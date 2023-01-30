//
//  Set + Ext.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation
import DevTools

extension Set where Element: MappedField {
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
