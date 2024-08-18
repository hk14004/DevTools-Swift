//
//  PersistedLayerInterface.swift
//  
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine

public protocol PersistedLayerInterface {
    associatedtype T: PersistableDomainModel
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async -> T?
    @discardableResult func getSingle(id: String) -> T?
    
    @discardableResult func getList(predicate: NSPredicate,
                                    sortDescriptors: [NSSortDescriptor]) async -> [T]
    @discardableResult func getList(predicate: NSPredicate,
                                    sortDescriptors: [NSSortDescriptor]) -> [T]
    
    @discardableResult func getListPage(pageOptions: PagedRequestOptions,
                                        predicate: NSPredicate,
                                        sortDescriptors: [NSSortDescriptor]) async -> PagedResult<T>
    @discardableResult func getListPage(pageOptions: PagedRequestOptions,
                                        predicate: NSPredicate,
                                        sortDescriptors: [NSSortDescriptor]) -> PagedResult<T>
    
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate,
                                        sortDescriptors: [NSSortDescriptor]) -> AnyPublisher<[T],Never>
    
    // Write
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>) async
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>)
    
    func delete(_ itemIds: [String]) async
    func delete(_ itemIds: [String])
    
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>) async
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>)
    
    func bulkWrite(operations: [() async -> Void]) async
}
