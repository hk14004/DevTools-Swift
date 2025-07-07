//
//  DevPersistedLayerInterface.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 06/07/2025.
//

import Foundation
import Combine
import DevToolsCore

public protocol DevPersistedLayerInterface {
    associatedtype DTO: DevDBInterfaceDTO
    associatedtype PredicateType
    associatedtype SortType
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async throws -> DTO?
    @discardableResult func getSingle(id: String) throws -> DTO?
    @discardableResult func getList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) async throws -> [DTO]
    @discardableResult func getList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) throws -> [DTO]
    
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) async throws -> DevPagedResult<DTO>
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) throws -> DevPagedResult<DTO>
    
    @discardableResult func observeSingle(id: String) -> AnyPublisher<DTO?, Error>
    @discardableResult func observeList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) -> AnyPublisher<[DTO], Error>
    
    // Write
    func addOrUpdate(_ items: [DTO]) async throws
    func addOrUpdate(_ items: [DTO]) throws
    
    func delete(_ itemIds: [String]) async throws
    func delete(_ itemIds: [String]) throws
    
    func replace(with items: [DTO]) async throws
    func replace(with items: [DTO]) throws
    
    func bulkWrite(block: @escaping () throws -> Void) async throws
    func bulkWrite(block: @escaping () throws -> Void) throws
}

public enum DevPersistedLayerInterfaceError: LocalizedError {
    case underlying(Error)
}
