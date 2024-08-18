//
//  Array+DevTableSection.swift
//
//
//  Created by Hardijs Ķirsis on 16/12/2023.
//

import Foundation

public extension Array where Element: DevTableSection {
    mutating func update(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.id == section.id}) else {
            return
        }
        remove(at: sectionIndex)
        insert(section, at: sectionIndex)
    }
    
    func getSection(id: Element.SectionID) -> Element? {
        return first(where: {$0.id == id})
    }
    
    mutating func remove(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.id == section.id}) else {
            return
        }
        remove(at: sectionIndex)
    }
    
    func hasSection(id: Element.SectionID) -> Bool {
        contains(where: {$0.id == id})
    }
    
    mutating func addOrUpdate(section: Element) {
        if hasSection(id: section.id) {
            update(section: section)
        } else {
            insert(section, at: self.count)
        }
    }
}
