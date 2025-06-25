//
//  PersistedLayerInterface.swift
//
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine

public protocol PersistedLayerInterface {
    associatedtype T: DBInterfaceDTO
    
    // Read & Observe
    @discardableResult func getSingle(
        id: String,
        fields: Set<T.StoreType.FieldType>
    ) async throws -> T?
    @discardableResult func getSingle(
        id: String,
        fields: Set<T.StoreType.FieldType>
    ) throws -> T?
    
    @discardableResult func getList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        fields: Set<T.StoreType.FieldType>
    ) async throws -> [T]
    @discardableResult func getList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        fields: Set<T.StoreType.FieldType>
    ) throws -> [T]
    
    @discardableResult func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        fields: Set<T.StoreType.FieldType>
    ) async throws -> PagedResult<T>
    @discardableResult func getListPage(
        pageOptions: PagedRequestOptions,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        fields: Set<T.StoreType.FieldType>
    ) throws -> PagedResult<T>
    
    @discardableResult func observeSingle(
        id: String,
        fields: Set<T.StoreType.FieldType>
    ) -> AnyPublisher<T?, Error>
    @discardableResult func observeList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        fields: Set<T.StoreType.FieldType>
    ) -> AnyPublisher<[T], Error>
    
    // Write
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>) async throws
    func addOrUpdate(_ items: [T], fields: Set<T.StoreType.FieldType>) throws
    
    func delete(_ itemIds: [String]) async throws
    func delete(_ itemIds: [String]) throws
    
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>) async throws
    func replace(with items: [T], fields: Set<T.StoreType.FieldType>) throws
    
    func bulkWrite(block: @escaping () throws -> Void) async throws
    func bulkWrite(block: @escaping () throws -> Void) throws
}
