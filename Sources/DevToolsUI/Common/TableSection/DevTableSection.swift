//
//  DevTableSection.swift
//
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation
import DevToolsCore

public protocol DevTableSection: Hashable, DevContentComparable {
    associatedtype Cell: Hashable, DevContentComparable
    associatedtype Identifier: CaseIterable, RawRepresentable, Hashable where Identifier.RawValue == String
    
    var identifier: Identifier { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

public typealias DevTableSectionCell = Hashable & DevContentComparable

public extension DevTableSection {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
