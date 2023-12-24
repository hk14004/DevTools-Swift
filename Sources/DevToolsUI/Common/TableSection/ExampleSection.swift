//
//  ExampleSection.swift
//
//
//  Created by Hardijs Ķirsis on 16/12/2023.
//

import DevToolsCore

fileprivate struct ExampleSection: DevTableSection {
    
    enum Identifier: String, CaseIterable {
        case SectionA
        case SectionB
    }
    
    enum Cell: Hashable, DevContentComparable {
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

public class NavigationItem: Equatable, Hashable, DevContentComparable {
    public let title: String
    public let subtitle: String
    private let navigateClosure: VoidCallback
    
    public init(title: String, subtitle: String, navigateClosure: @escaping VoidCallback) {
        self.title = title
        self.subtitle = subtitle
        self.navigateClosure = navigateClosure
    }
    
    public func navigate() {
        navigateClosure()
    }
}

public extension NavigationItem {
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
    }
}
