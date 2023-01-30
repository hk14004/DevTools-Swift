//
//  File.swift
//  
//
//  Created by Hardijs on 30/01/2023.
//

import Foundation
import Combine

public protocol RepositoryProtocol {
    associatedtype T: PersistableDomainModelProtocol
    
    @discardableResult func getSingle(id: String) -> T?
    @discardableResult func getList(predicate: NSPredicate) -> [T]
    @discardableResult func addOrUpdate(_ items: [T]) -> Bool
    @discardableResult func delete(_ items: [T]) -> Bool
    @discardableResult func replace(with items: [T]) -> Bool
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate) -> AnyPublisher<[T],Never>
}
