//
//  PersistedLayerInterface.swift
//
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine
import DevToolsCore

public protocol DevPersistedLayerInterface {
    associatedtype T: DevDBInterfaceDTO
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async throws -> T?
    @discardableResult func getSingle(id: String) throws -> T?
    @discardableResult func getList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) async throws -> [T]
    @discardableResult func getList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [T]
    
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) async throws -> DevPagedResult<T>
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> DevPagedResult<T>
    
    @discardableResult func observeSingle(id: String,) -> AnyPublisher<T?, Error>
    @discardableResult func observeList(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) -> AnyPublisher<[T], Error>
    
    // Write
    func addOrUpdate(_ items: [T]) async throws
    func addOrUpdate(_ items: [T]) throws
    
    func delete(_ itemIds: [String]) async throws
    func delete(_ itemIds: [String]) throws
    
    func replace(with items: [T]) async throws
    func replace(with items: [T]) throws
    
    func bulkWrite(block: @escaping () throws -> Void) async throws
    func bulkWrite(block: @escaping () throws -> Void) throws
}
