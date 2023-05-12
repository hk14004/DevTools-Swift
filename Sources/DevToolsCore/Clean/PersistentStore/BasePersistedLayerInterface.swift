//
//  BasePersistedLayerInterface.swift
//  
//
//  Created by Hardijs Ķirsis on 12/05/2023.
//

import Foundation
import Combine

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
    
    open func getListPage(pageOptions: PagedRequestOptions,
                          predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> PagedResult<T> {
        fatalError()
    }
    
    open func getList(predicate: NSPredicate,
                      sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> [T] {
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
    
    open func getList(predicate: NSPredicate,
                      sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async -> [T] {
        fatalError()
    }
    
    open func getListPage(pageOptions: PagedRequestOptions,
                          predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) async -> PagedResult<T> {
        fatalError()
    }
    
    open func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        fatalError()
    }
    
    open func observeList(predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()]
    ) -> AnyPublisher<[T], Never> {
        fatalError()
    }
    
    open func delete(_ itemIds: [String]) async {
        fatalError()
    }
    
    open func bulkWrite(operations: [() async -> Void]) async {
        fatalError()
    }
}

