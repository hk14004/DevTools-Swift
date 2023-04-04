//
//  PersistedLayerInterface.swift
//  
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine

// TODO: Add pagination

public protocol PersistedLayerInterface {
    associatedtype T: PersistableDomainModelProtocol
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async -> T?
    @discardableResult func getList(predicate: NSPredicate,
                                    sortedByKeyPath: String,
                                    ascending: Bool) async -> [T]
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate,
                                        sortedByKeyPath: String,
                                        ascending: Bool) -> AnyPublisher<[T],Never>
    
    // Write
    func addOrUpdate(_ items: [T]) async
    func delete(_ items: [T]) async
    func replace(with items: [T]) async
    func bulkWrite(operations: [() async -> Void]) async
}
