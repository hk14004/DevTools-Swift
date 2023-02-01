//
//  File.swift
//  
//
//  Created by Cube on 01/02/2023.
//

import Foundation

public func sanityCheck(name: String = "SANITY-CHECK", operation: ()->()) {
    let symbols = "###########"
    print(symbols + " " + name + "-START" + " " + symbols)
    operation()
    print(symbols + " " + name + "-END" + " " + symbols)
}
