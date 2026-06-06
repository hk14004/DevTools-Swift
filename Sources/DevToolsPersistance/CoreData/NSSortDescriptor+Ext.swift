//
//  NSSortDescriptor + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 12/05/2023.
//

import CoreData

public extension NSSortDescriptor {
    static func makeStringIDSortDescriptor() -> NSSortDescriptor {
        NSSortDescriptor(key: "id",
                         ascending: true,
                         selector: #selector(NSString.localizedStandardCompare(_:)))
    }
}
