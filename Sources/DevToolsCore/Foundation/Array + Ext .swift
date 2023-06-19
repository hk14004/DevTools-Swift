//
//  Array + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Array {
    mutating func shuffle() {
        for i in 0..<count {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {
                swapAt(i, j)
            }
        }
    }
}

public extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for item in self {
            if !result.contains(item) {
                result.append(item)
            }
        }
        return result
    }
}
