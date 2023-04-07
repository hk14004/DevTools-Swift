//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 07/04/2023.
//

import Foundation
import RealmSwift

extension Results where Element: KeypathSortable {
    public func optionallySorted(byKeyPath: String = "", ascending: Bool = true) -> Results<Element> {
        if byKeyPath.isEmpty {
            return self
        } else {
            return self.sorted(byKeyPath: byKeyPath, ascending: ascending)
        }
    }
}
