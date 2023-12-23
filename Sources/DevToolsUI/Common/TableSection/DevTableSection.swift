//
//  UISectionModel.swift
//
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation
import DevToolsCore

public protocol DevTableSection {
    associatedtype Cell: Hashable, ContentComparable
    associatedtype Identifier: CaseIterable, RawRepresentable, Hashable where Identifier.RawValue == String
    
    var identifier: Identifier { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

public extension ContentComparable where Self: Hashable {
    var contentHash: Int {
        var hasher = Hasher()
        let mirror = Mirror(reflecting: self)

        for case let (_?, value) in mirror.children {
            if let value = value as? ContentComparable {
                hasher.combine(value.contentHash)
                continue
            }
            if let hashable = value as? (any Hashable) {
                hasher.combine(hashable)
            }
        }

        return hasher.finalize()
    }
}
