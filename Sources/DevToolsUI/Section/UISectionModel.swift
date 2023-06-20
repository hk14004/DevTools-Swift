//
//  UISectionModelProtocol.swift
//  
//
//  Created by Cube on 04/02/2023.
//

import Foundation
import DevToolsCore

public protocol UISectionModel {
    associatedtype Cell: Hashable
    associatedtype Identifier: CaseIterable, RawRepresentable, Hashable where Identifier.RawValue == String
    
    var identifier: Identifier { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}

fileprivate struct ExampleSection: UISectionModel {
    
    enum Identifier: String, CaseIterable {
        case SectionA
        case SectionB
    }
    
    enum Cell: Hashable {
        case emptyCell
        case showText
        case navigate(NavigationItem)
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

public extension Array where Element: UISectionModel {
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
    
    mutating func addOrUpdate(section: Element) {
        if hasSection(id: section.identifier) {
            update(section: section)
        } else {
            insert(section, at: self.count)
        }
    }
}

public class NavigationItem: Equatable, Hashable {
    let title: String
    let subtitle: String
    private let navigateClosure: VoidCallback
    
    init(title: String, subtitle: String, navigateClosure: @escaping VoidCallback) {
        self.title = title
        self.subtitle = subtitle
        self.navigateClosure = navigateClosure
    }
    
    func navigate() {
        navigateClosure()
    }
}

extension NavigationItem {
    public static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
    }
}
