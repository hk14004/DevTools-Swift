//
//  BasePersistedLayerInterface.swift
//
//
//  Created by Hardijs Ķirsis on 12/05/2023.
//

import Foundation
import Combine

enum PersistenceError: Error {
    case notImplemented
}

open class BasePersistedLayerInterface<T: DBInterfaceDTO>: PersistedLayerInterface {
    // MARK: Lifecycle
    
    public init() {}
    
    // MARK: Read
    // Single
    open func getSingle(
        id: String,
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws -> T? {
        throw PersistenceError.notImplemented
    }
    
    open func getSingle(
        id: String,
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws -> T? {
        throw PersistenceError.notImplemented
    }
    
    // List
    open func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws -> [T] {
        throw PersistenceError.notImplemented
    }
    
    open func getList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws -> [T] {
        throw PersistenceError.notImplemented
    }
    
    // Paging
    open func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws -> PagedResult<T> {
        throw PersistenceError.notImplemented
    }

    open func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws -> PagedResult<T> {
        throw PersistenceError.notImplemented
    }
    
    // MARK: Write
    // Amend
    open func addOrUpdate(
        _ items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws {
        throw PersistenceError.notImplemented
    }
    
    open func addOrUpdate(
        _ items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws {
        throw PersistenceError.notImplemented
    }
    
    // Delete
    open func delete(_ itemIds: [String]) throws {
        throw PersistenceError.notImplemented
    }
    
    open func delete(_ itemIds: [String]) async throws {
        throw PersistenceError.notImplemented
    }
    
    open func replace(
        with items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) throws {
        throw PersistenceError.notImplemented
    }

    open func replace(
        with items: [T],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) async throws {
        throw PersistenceError.notImplemented
    }
    
    // Bulk
    open func bulkWrite(block: @escaping () throws -> Void) async throws {
        throw PersistenceError.notImplemented
    }
    
    open func bulkWrite(block: @escaping () throws -> Void) throws {
        throw PersistenceError.notImplemented
    }
    
    // MARK: Observe
    
    open func observeSingle(
        id: String,
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) -> AnyPublisher<T?, Error> {
        .fail(PersistenceError.notImplemented)
    }
    
    open func observeList(
        predicate: NSPredicate = NSPredicate(value: true),
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor.makeStringIDSortDescriptor()],
        fields: Set<T.StoreType.FieldType> = T.StoreType.FieldType.getSetOfAllFields()
    ) -> AnyPublisher<[T], Error> {
        .fail(PersistenceError.notImplemented)
    }
}
