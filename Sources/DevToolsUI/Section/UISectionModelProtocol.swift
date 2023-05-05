//
//  UISectionModelProtocol.swift
//  
//
//  Created by Cube on 04/02/2023.
//

import Foundation

public protocol UISectionModelProtocol {
    associatedtype Cell: Hashable
    associatedtype Identifier: CaseIterable, RawRepresentable, Hashable where Identifier.RawValue == String
    
    var identifier: Identifier { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

fileprivate struct ExampleSection: UISectionModelProtocol {
    
    enum Identifier: String, CaseIterable {
        case SectionA
        case SectionB
    }
    
    enum Cell: Hashable {
        case emptyCell
        case showText
    }
    
    let identifier: Identifier
    var title: String
    var cells: [Cell]
    
    init(identifier: Identifier, title: String, cells: [Cell]) {
        self.identifier = identifier
        self.title = title
        self.cells = cells
    }
}

public extension Array where Element: UISectionModelProtocol {
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
        return contains(where: {$0.identifier == id})
    }
}
