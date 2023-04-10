//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 07/04/2023.
//

import RealmSwift
import DevToolsCore

extension Results where Element: PersistedModelProtocol {
    func mapToDomain(fetchOffset: Int, fetchLimit: Int, fields: Set<Element.FieldType>) -> [Element.DomainModelType] {
        let endIndex: Int = {
           let wantIndex = fetchOffset + fetchLimit - 1
            return [wantIndex, self.count-1].min()!
        }()
        var items: [Element.DomainModelType] = []
        guard fetchOffset <= endIndex else {
            return []
        }
        for index in fetchOffset...endIndex {
            guard let stored = self[safe: index] else {
                continue
            }
            guard let converted = try? stored.toDomain(fields: fields) else {
                continue
            }
            items.append(converted)
        }
        return items
    }

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
