//
//  Optional + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Optional {
    func unwrapped(or defaultValue: Wrapped) -> Wrapped {
        return self ?? defaultValue
    }
}
