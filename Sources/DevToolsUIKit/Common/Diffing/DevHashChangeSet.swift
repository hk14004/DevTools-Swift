import Foundation

public struct DevHashChangeSet {
    public typealias CellID = Int
    public var inserted: [CellID]
    public var removed: [CellID]
    public var updated: [CellID]
    
    public init(
        inserted: [CellID] = [],
        removed: [CellID] = [],
        updated: [CellID] = []
    ) {
        self.inserted = inserted
        self.removed = removed
        self.updated = updated
    }
    
    public init<Element: Hashable & DevContentComparable>(
        old: [Element] = [],
        new: [Element] = []
    ) {
        self = Self.calculateChangeSet(old: old, new: new)
    }
}

public extension DevHashChangeSet {
    static func calculateChangeSet<Element: Hashable & DevContentComparable>(
        old: [Element],
        new: [Element]
    ) -> DevHashChangeSet {
        var changeSet = DevHashChangeSet(inserted: [], removed: [], updated: [])

        // Create lookup dictionaries for fast access
        let oldDict = Dictionary(uniqueKeysWithValues: old.map { ($0.hashValue, $0) })
        let newDict = Dictionary(uniqueKeysWithValues: new.map { ($0.hashValue, $0) })

        let oldSet = Set(oldDict.keys)
        let newSet = Set(newDict.keys)

        let insertedSet = newSet.subtracting(oldSet)
        changeSet.inserted = Array(insertedSet)

        let removedSet = oldSet.subtracting(newSet)
        changeSet.removed = Array(removedSet)

        // Comparison for updated items
        let commonSet = oldSet.intersection(newSet)
        for key in commonSet {
            if let oldElement = oldDict[key], let newElement = newDict[key],
               !(oldElement |==| newElement) {
                changeSet.updated.append(key)
            }
        }

        return changeSet
    }
}
