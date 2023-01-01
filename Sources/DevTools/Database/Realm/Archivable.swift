//
//  Archivable.swift
//  
//
//  Created by Hardijs on 01/01/2023.
//

import Foundation

public protocol Archivable: AnyObject {
    var isArchived: Bool { get set }
    func archive(_ archive: Bool)
}

extension Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}
