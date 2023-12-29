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

public protocol DevTableSectionCell: DevContentComparable, Hashable {}

public extension DevTableSectionCell {
    var contentHash: Int {
        fatalError("Must be implement by cell")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        fatalError("Must be implement by cell")
    }
    
    func hash(into hasher: inout Hasher) {
        fatalError("Must be implement by cell")
    }
}

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

public extension DevHashChangeSet {
    static func calculateCellChangeSet<Element: DevTableSection>(
        old: [Element],
        new: [Element]
    ) -> DevHashChangeSet {
        func getCells(section: [Element]) -> [Element.Cell] {
            section.map { section in
                section.cells
            }
            .flatMap { item in
                item
            }
        }
        let oldCells = getCells(section: old)
        let newCells = getCells(section: new)
        return DevHashChangeSet.calculateChangeSet(old: oldCells, new: newCells)
    }
}
