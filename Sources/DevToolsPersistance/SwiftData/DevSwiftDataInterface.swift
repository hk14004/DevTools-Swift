//
//  DevSwiftDataInterface.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 06/07/2025.
//

import Foundation

public protocol DevSwiftDataInterface: DevPersistedLayerInterface where PredicateType == Predicate<DTO.StoreType>, SortType == SortDescriptor<DTO.StoreType> {}
