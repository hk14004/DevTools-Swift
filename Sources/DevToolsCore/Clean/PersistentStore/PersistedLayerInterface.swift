//
//  PersistedLayerInterface.swift
//  
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine

public protocol PersistedLayerInterface {
    associatedtype T: PersistableDomainModelProtocol
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async -> T?
    @discardableResult func getSingle(id: String) -> T?
    
    @discardableResult func getList(predicate: NSPredicate,
                                    sortedByKeyPath: String,
                                    ascending: Bool) async -> [T]
    @discardableResult func getList(predicate: NSPredicate,
                                    sortedByKeyPath: String,
                                    ascending: Bool) -> [T]
    
    @discardableResult func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate,
                                        sortedByKeyPath: String,
                                        ascending: Bool) async -> PagedResult<T>
    @discardableResult func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate,
                                        sortedByKeyPath: String,
                                        ascending: Bool) -> PagedResult<T>
    
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate,
                                        sortedByKeyPath: String,
                                        ascending: Bool) -> AnyPublisher<[T],Never>
    
    // Write
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>) async
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>)
    
    func delete(_ itemIds: [String]) async
    func delete(_ itemIds: [String])
    
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>) async
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>)
    
    func bulkWrite(operations: [() async -> Void]) async
}

open class BasePersistedLayerInterface<T: PersistableDomainModelProtocol>: PersistedLayerInterface {
    open func replace(with items: [T], fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) {
        fatalError()
    }
    
    open func delete(_ itemIds: [String]) {
        fatalError()
    }
    
    open func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) {
        fatalError()
    }
    
    open func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> PagedResult<T> {
        fatalError()
    }
    
    open func getList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> [T] {
        fatalError()
    }
    
    open func getSingle(id: String) -> T? {
        fatalError()
    }
    
    public init() {}
    
    open func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        fatalError()
    }
    
    open func replace(with items: [T], fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()) async {
        fatalError()
    }
    
    open func getSingle(id: String) async -> T? {
        fatalError()
    }
    
    open func getList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> [T] {
        fatalError()
    }
    
    open func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> PagedResult<T> {
        fatalError()
    }
    
    open func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        fatalError()
    }
    
    open func observeList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> AnyPublisher<[T], Never> {
        fatalError()
    }
    
    open func delete(_ itemIds: [String]) async {
        fatalError()
    }
    
    open func bulkWrite(operations: [() async -> Void]) async {
        fatalError()
    }
}
