//
//  DevCoreDataInterface.swift
//
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation

public protocol DevCoreDataInterface: DevPersistedLayerInterface where PredicateType == NSPredicate, SortType == NSSortDescriptor {}
