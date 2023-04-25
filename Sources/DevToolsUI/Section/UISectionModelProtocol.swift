//
//  UISectionModelProtocol.swift
//  
//
//  Created by Cube on 04/02/2023.
//

import Foundation

public protocol UISectionModelProtocol {
    associatedtype Cell: Hashable
    
    var uuid: String { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

fileprivate struct ExampleSection: UISectionModelProtocol {
    
    enum Cell: Hashable {
        case emptyCell
        case showText
    }
    
    let uuid: String
    var title: String
    var cells: [Cell]
    
    init(uuid: String, title: String, cells: [Cell]) {
        self.uuid = uuid
        self.title = title
        self.cells = cells
    }
}

public extension Array where Element: UISectionModelProtocol {
    mutating func update(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.uuid == section.uuid}) else {
            return
        }
        remove(at: sectionIndex)
        insert(section, at: sectionIndex)
    }
    
    func getSection(uuid: String) -> Element? {
        return first(where: {$0.uuid == uuid})
    }
    
    mutating func remove(section: Element) {
        guard let sectionIndex = firstIndex(where: {$0.uuid == section.uuid}) else {
            return
        }
        remove(at: sectionIndex)
    }
    
    func hasSection(uuid: String) -> Bool {
        return contains(where: {$0.uuid == uuid})
    }
}
