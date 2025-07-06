//
//  DevDBInterfaceDTO.swift
//  
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation

public protocol DevDBInterfaceDTO {
    associatedtype StoreType: DevDBStoredObject
    var id: String { get }
}
