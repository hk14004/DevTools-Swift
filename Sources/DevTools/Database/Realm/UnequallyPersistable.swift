//
//  UnequallyPersistable.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation

public protocol UnequallyPersistable: AnyObject {
    var id: String { get set }
}
