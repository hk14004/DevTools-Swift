//
//  DBInterfaceDTO.swift
//  
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation

public protocol DBInterfaceDTO {
    associatedtype StoreType: DBStoredObject
    var id: String { get }
}
