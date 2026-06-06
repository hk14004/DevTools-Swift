//
//  SanityCheck.swift
//  
//
//  Created by Hardijs on 01/02/2023.
//

import Foundation

#if DEBUG
public func sanityCheck(name: String = "SANITY-CHECK", operation: () -> Void) {
    let symbols = "###########"
    print(symbols + " " + name + "-START" + " " + symbols)
    operation()
    print(symbols + " " + name + "-END" + " " + symbols)
}
#endif
