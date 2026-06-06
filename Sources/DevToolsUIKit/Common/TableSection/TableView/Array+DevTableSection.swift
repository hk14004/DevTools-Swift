//
//  Array+DevTableSection.swift
//
//
//  Created by Hardijs Ķirsis on 16/12/2023.
//

import Foundation

// MARK: - Deprecated

/// These array extensions are superseded by ``DevSectionStore``, which provides
/// O(1) lookup, explicit ordering, atomic cell updates, and dynamic SectionIDs.
///
/// Migration guide:
/// - `addOrUpdate(section:)`  → `store.set(_:)`
/// - `update(section:)`       → `store.set(_:)`
/// - `getSection(id:)`        → `store[id]`
/// - `hasSection(id:)`        → `store.contains(id:)`
/// - `remove(section:)`       → `store.remove(id:)`
/// - `array.asSnapshot()`     → `store.asSnapshot()`
public extension Array where Element: DevTableSection {

    @available(*, deprecated, renamed: "DevSectionStore.set(_:)", message: "Use DevSectionStore instead. See Array+DevTableSection.swift migration guide.")
    mutating func update(section: Element) {
        guard let sectionIndex = firstIndex(where: { $0.id == section.id }) else { return }
        remove(at: sectionIndex)
        insert(section, at: sectionIndex)
    }

    @available(*, deprecated, renamed: "DevSectionStore.subscript(_:)", message: "Use DevSectionStore instead. See Array+DevTableSection.swift migration guide.")
    func getSection(id: Element.SectionID) -> Element? {
        return first(where: { $0.id == id })
    }

    @available(*, deprecated, renamed: "DevSectionStore.remove(id:)", message: "Use DevSectionStore instead. See Array+DevTableSection.swift migration guide.")
    mutating func remove(section: Element) {
        guard let sectionIndex = firstIndex(where: { $0.id == section.id }) else { return }
        remove(at: sectionIndex)
    }

    @available(*, deprecated, renamed: "DevSectionStore.contains(id:)", message: "Use DevSectionStore instead. See Array+DevTableSection.swift migration guide.")
    func hasSection(id: Element.SectionID) -> Bool {
        contains(where: { $0.id == id })
    }

    @available(*, deprecated, renamed: "DevSectionStore.set(_:)", message: "Use DevSectionStore instead. See Array+DevTableSection.swift migration guide.")
    mutating func addOrUpdate(section: Element) {
        if let idx = firstIndex(where: { $0.id == section.id }) {
            remove(at: idx)
            insert(section, at: idx)
        } else {
            append(section)
        }
    }
}
