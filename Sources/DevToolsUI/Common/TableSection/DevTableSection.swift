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
    associatedtype SectionID: CaseIterable, RawRepresentable, Hashable where SectionID.RawValue == String
    
    var id: SectionID { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

public typealias DevTableSectionCell = Hashable & DevContentComparable

public extension DevTableSection {
    var contentHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(cells.contentHash)
        return hasher.finalize()
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
