//
//  PersistableDomainModel.swift
//  
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation

// All domain models should implement this protocol

public protocol PersistableDomainModel {
    associatedtype StoreType: PersistedModel
    var id: String { get }
}
