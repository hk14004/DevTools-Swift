import Foundation

public struct DevHashChangeSet {
    public typealias CellID = Int
    public var inserted: [CellID]
    public var removed: [CellID]
    public var updated: [CellID]
}

public extension DevHashChangeSet {
    static func calculateChangeSet<Element: Hashable & DevContentComparable>(
        old: [Element],
        new: [Element]
    ) -> DevHashChangeSet {
        var changeSet = DevHashChangeSet(inserted: [], removed: [], updated: [])
        
        let oldSet = Set(old)
        let newSet = Set(new)
        
        let insertedSet = newSet.subtracting(oldSet)
        changeSet.inserted = Array(insertedSet).map(\.hashValue)
        
        let removedSet = oldSet.subtracting(newSet)
        changeSet.removed = Array(removedSet).map(\.hashValue)
        
        // Calculate updated items
        let commonSet = oldSet.intersection(newSet)
        for element in commonSet {
            if let oldElement = old.first(where: { $0.hashValue == element.hashValue }),
               let newElement = new.first(where: { $0.hashValue == element.hashValue }),
               !(oldElement |==| newElement) {
                changeSet.updated.append(element.hashValue)
            }
        }
        
        return changeSet
    }
}
