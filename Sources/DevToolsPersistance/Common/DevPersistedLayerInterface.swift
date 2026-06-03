//
//  DevPersistedLayerInterface.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 06/07/2025.
//

import Foundation
import Combine
import DevToolsCore

/// The async-primary contract for a persistence store.
///
/// This is the minimal interface any backend must satisfy — all operations are async.
/// For stores that can also offer synchronous access (CoreData, SwiftData on a background queue),
/// adopt `DevSyncPersistedLayerInterface` instead.
public protocol DevPersistedLayerInterface {
    associatedtype DTO: DevDBInterfaceDTO
    associatedtype PredicateType
    associatedtype SortType

    // MARK: Read & Observe

    @discardableResult func getSingle(id: String) async throws -> DTO?
    @discardableResult func getList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) async throws -> [DTO]
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) async throws -> DevPagedResult<DTO>

    @discardableResult func observeSingle(id: String) -> AnyPublisher<DTO?, Error>
    @discardableResult func observeList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) -> AnyPublisher<[DTO], Error>

    // MARK: Write

    func addOrUpdate(_ items: [DTO]) async throws
    func delete(_ itemIds: [String]) async throws
    func replace(with items: [DTO]) async throws

    /// Groups multiple writes into a single save. The block runs synchronously on the
    /// store's internal queue; call only the sync variants of write methods inside it.
    func bulkWrite(block: @escaping () throws -> Void) async throws
}

/// Extends `DevPersistedLayerInterface` with synchronous equivalents for every operation.
///
/// Adopt this when the underlying store can offer blocking APIs without risk of deadlock
/// (e.g. CoreData's `performAndWait`, SwiftData on a dedicated background queue).
/// App code that only needs async should depend on `DevPersistedLayerInterface`.
public protocol DevSyncPersistedLayerInterface: DevPersistedLayerInterface {

    // MARK: Read (sync)

    @discardableResult func getSingle(id: String) throws -> DTO?
    @discardableResult func getList(
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) throws -> [DTO]
    @discardableResult func getListPage(
        pageOptions: DevPagedRequestOptions,
        predicate: PredicateType?,
        sortDescriptors: [SortType]
    ) throws -> DevPagedResult<DTO>

    // MARK: Write (sync)

    func addOrUpdate(_ items: [DTO]) throws
    func delete(_ itemIds: [String]) throws
    func replace(with items: [DTO]) throws

    /// Synchronous bulk write. The block is called immediately on the calling thread;
    /// it does not escape, and changes are committed in a single save at the end.
    func bulkWrite(block: () throws -> Void) throws
}

public enum DevPersistedLayerInterfaceError: LocalizedError {
    case underlying(Error)
}
