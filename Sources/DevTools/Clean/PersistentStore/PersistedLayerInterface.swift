//
//  PersistedLayerInterface.swift
//  
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import Combine

public class BasePersistedLayerInterface<T: PersistableDomainModelProtocol>: PersistedLayerInterface {
    public func getSingle(id: String) async -> T? {
        fatalError()
    }
    
    public func getList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> [T] {
        fatalError()
    }
    
    public func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) async -> PagedResult<T> {
        fatalError()
    }
    
    public func observeSingle(id: String) -> AnyPublisher<T?, Never> {
        fatalError()
    }
    
    public func observeList(predicate: NSPredicate, sortedByKeyPath: String, ascending: Bool) -> AnyPublisher<[T], Never> {
        fatalError()
    }
    
    public func addOrUpdate(_ items: [T]) async {
        fatalError()
    }
    
    public func delete(_ items: [T]) async {
        fatalError()
    }
    
    public func replace(with items: [T]) async {
        fatalError()
    }
    
    public func bulkWrite(operations: [() async -> Void]) async {
        fatalError()
    }
}

public protocol PersistedLayerInterface {
    associatedtype T: PersistableDomainModelProtocol
    
    // Read & Observe
    @discardableResult func getSingle(id: String) async -> T?
    @discardableResult func getList(predicate: NSPredicate,
                                    sortedByKeyPath: String,
                                    ascending: Bool) async -> [T]
    @discardableResult func getListPage(pageOptions: PagedRequestOptions, predicate: NSPredicate,
                                    sortedByKeyPath: String,
                                    ascending: Bool) async -> PagedResult<T>
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate,
                                        sortedByKeyPath: String,
                                        ascending: Bool) -> AnyPublisher<[T],Never>
    
    // Write
    func addOrUpdate(_ items: [T]) async
    func delete(_ items: [T]) async
    func replace(with items: [T]) async
    func bulkWrite(operations: [() async -> Void]) async
}

public struct PagedResult<T> {
    public let pageNumber: Int
    public let pageItems: [T]
    public let hasNextPage: Bool
    
    public init(pageNumber: Int, pageItems: [T], hasNextPage: Bool) {
        self.pageNumber = pageNumber
        self.pageItems = pageItems
        self.hasNextPage = hasNextPage
    }
    
}
public struct PagedRequestOptions {
    public let fetchPage: Int
    public let pageSize: Int
    
    public init(fetchPage: Int, pageSize: Int) {
        self.fetchPage = fetchPage
        self.pageSize = pageSize
    }
}
