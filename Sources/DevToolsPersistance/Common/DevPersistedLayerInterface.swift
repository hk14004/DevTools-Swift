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
/// All writes are async — they always execute on a background context so reads
/// are never blocked by an in-flight write. Reads are available in both async
/// and (via `DevSyncPersistedLayerInterface`) sync forms.
///
/// App-layer code should depend on this protocol unless it specifically needs
/// synchronous read access.
public protocol DevPersistedLayerInterface {
    associatedtype DTO: DevDBInterfaceDTO
    associatedtype PredicateType
    associatedtype SortType

    // MARK: Read & Observe (async)

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

    // MARK: Write (always async — executes on a background context)

    func addOrUpdate(_ items: [DTO]) async throws
    func delete(_ itemIds: [String]) async throws
    func replace(with items: [DTO]) async throws

    /// Groups multiple writes into a single background save, firing observers only once.
    /// The block is async — call the store's normal async write methods inside it.
    /// Individual saves are suppressed until the block completes.
    func bulkWrite(block: @escaping () async throws -> Void) async throws
}

/// Extends `DevPersistedLayerInterface` with synchronous read access.
///
/// Reads execute on the store's dedicated view/read context which is always
/// up to date and never blocked by background writes. Safe to call from the
/// main thread for small, indexed lookups (e.g. `getSingle(id:)`). For large
/// result sets prefer the async variants or `observeList`.
///
/// Note: sync WRITES are intentionally absent — all mutations go to a
/// background context and are therefore always async.
public protocol DevSyncPersistedLayerInterface: DevPersistedLayerInterface {

    // MARK: Read (sync — view context, never blocks on writes)

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
}

