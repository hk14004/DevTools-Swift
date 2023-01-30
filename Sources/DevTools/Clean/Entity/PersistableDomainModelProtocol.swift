//
//  File.swift
//  
//
//  Created by Cube on 30/01/2023.
//

import Foundation

// All domain models should implement this protocol

public protocol PersistableDomainModelProtocol: Identifiable {
    associatedtype StoreType: PersistedModelProtocol
}
