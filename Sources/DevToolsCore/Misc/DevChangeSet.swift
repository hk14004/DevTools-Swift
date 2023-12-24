//
//  DevChangeSet.swift
//
//
//  Created by Hardijs Ķirsis on 24/12/2023.
//

import UIKit

public struct DevChangeSet {
    var inserted: [IndexPath]
    var removed: [IndexPath]
    var updated: [IndexPath]
    var moved: [(from: IndexPath, to: IndexPath)]
}

public extension DevChangeSet {
    static func calculateChangeSet<Element: Hashable & DevContentComparable>(old: [Element], new: [Element]) -> DevChangeSet {
        var changeSet = DevChangeSet(inserted: [], removed: [], updated: [], moved: [])
        
        let oldSet = Set(old)
        let newSet = Set(new)
        
        let insertedSet = newSet.subtracting(oldSet)
        let removedSet = oldSet.subtracting(newSet)
        
        // Calculate removed items' indexPaths
        for (index, element) in old.enumerated() {
            if removedSet.contains(element) {
                changeSet.removed.append(IndexPath(row: index, section: 0))
            }
        }
        
        // Calculate inserted items' indexPaths
        for (index, element) in new.enumerated() {
            if insertedSet.contains(element) {
                changeSet.inserted.append(IndexPath(row: index, section: 0))
            }
        }
        
        // Calculate moved items' indexPaths
        let commonSet = oldSet.intersection(newSet)
        for commonElement in commonSet {
            if let oldIndex = old.firstIndex(of: commonElement),
               let newIndex = new.firstIndex(of: commonElement),
               oldIndex != newIndex {
                let fromIndexPath = IndexPath(row: oldIndex, section: 0)
                let toIndexPath = IndexPath(row: newIndex, section: 0)
                changeSet.moved.append((from: fromIndexPath, to: toIndexPath))
            }
        }
        
        // Calculate updated items' indexPaths
        for (index, element) in new.enumerated() {
            if let oldIndex = old.firstIndex(of: element),
               old[oldIndex].contentHash != element.contentHash {
                changeSet.updated.append(IndexPath(row: index, section: 0))
            }
        }
        
        return changeSet
    }
}
