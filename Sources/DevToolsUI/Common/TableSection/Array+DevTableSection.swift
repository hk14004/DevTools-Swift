//
//  Array+DevTableSection.swift
//
//
//  Created by Hardijs Ķirsis on 16/12/2023.
//

import Foundation

public extension Array where Element: DevTableSection {
    mutating func update(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.identifier == section.identifier}) else {
            return
        }
        remove(at: sectionIndex)
        insert(section, at: sectionIndex)
    }
    
    func getSection(id: Element.Identifier) -> Element? {
        return first(where: {$0.identifier == id})
    }
    
    mutating func remove(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.identifier == section.identifier}) else {
            return
        }
        remove(at: sectionIndex)
    }
    
    func hasSection(id: Element.Identifier) -> Bool {
        contains(where: {$0.identifier == id})
    }
    
    mutating func addOrUpdate(section: Element) {
        if hasSection(id: section.identifier) {
            update(section: section)
        } else {
            insert(section, at: self.count)
        }
    }
}
