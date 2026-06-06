//
//  Array+DevTableSection+Snapshot.swift
//
//
//  Created by Hardijs on 04/06/2026.
//

import UIKit

public extension Array where Element: DevTableSection {

    /// Converts a `[DevTableSection]` array into an `NSDiffableDataSourceSnapshot`.
    ///
    /// - Note: Prefer ``DevSectionStore/asSnapshot()`` for new code. This extension
    ///   is kept for compatibility but does not benefit from the store's ordering guarantees.
    @available(*, deprecated, renamed: "DevSectionStore.asSnapshot()", message: "Use DevSectionStore instead.")
    func asSnapshot() -> NSDiffableDataSourceSnapshot<Element.SectionID, Element.Cell> {
        var snapshot = NSDiffableDataSourceSnapshot<Element.SectionID, Element.Cell>()
        let sectionIDs = map { $0.id }
        snapshot.appendSections(sectionIDs)
        forEach { section in
            snapshot.appendItems(section.cells, toSection: section.id)
        }
        return snapshot
    }
}
