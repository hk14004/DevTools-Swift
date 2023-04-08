//
//  WeakWrapper.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

class WeakWrapper<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}
