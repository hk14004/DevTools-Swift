//
//  File.swift
//  
//
//  Created by Cube on 31/12/2022.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
