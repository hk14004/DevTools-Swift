//
//  Collection + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
