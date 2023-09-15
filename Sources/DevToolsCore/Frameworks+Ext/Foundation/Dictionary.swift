//
//  Dictionary + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { self[$0] = $1 }
    }
}
