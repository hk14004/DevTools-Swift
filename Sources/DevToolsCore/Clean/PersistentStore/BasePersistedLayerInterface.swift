//
//  BasePersistedLayerInterface.swift
//
//
//  Created by Hardijs Ķirsis on 12/05/2023.
//

import Foundation
import Combine

open class BasePersistedLayerInterface<T: PersistableDomainModel>: PersistedLayerInterface {
    // MARK: Lifecycle
    
    public init() {}
    
    // MARK: Read
    // Single
    open func getSingle(id: String) -> T? {
        fatalError()
    }
    
    open func getSingle(id: String) async -> T? {
        fatalError()
    }
    
    // List
    open func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> [T] {
        fatalError()
    }
    
    open func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async -> [T] {
        fatalError()
    }
    
    // Paging
    open func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> PagedResult<T> {
        fatalError()
    }

    open func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async -> PagedResult<T> {
        fatalError()
    }
    
    // MARK: Write
    // Amend
    open func addOrUpdate(
        _ items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) {
        fatalError()
    }
    
    open func addOrUpdate(
        _ items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async {
        fatalError()
    }
    
    // Delete
    open func delete(_ itemIds: [String]) {
        fatalError()
    }
    
    open func delete(_ itemIds: [String]) async {
        fatalError()
    }
    
    open func replace(
        with items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) {
        fatalError()
    }

    open func replace(
        with items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async {
        fatalError()
    }
    
    // Bulk
    open func bulkWrite(operations: [() async -> Void]) async {
        fatalError()
    }
    
    // MARK: Observe
    
    open func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        fatalError()
    }
    
    open func observeList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> AnyPublisher<[T], Never> {
        fatalError()
    }
}
