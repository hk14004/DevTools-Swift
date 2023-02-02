//
//  File.swift
//  
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import Combine

// TODO: Add sorting predicate

public protocol PersistedLayerInterface {
    associatedtype T: PersistableDomainModelProtocol
    
    // Read & Observe
    @discardableResult func getSingle(id: String) -> T?
    @discardableResult func getList(predicate: NSPredicate) -> [T]
    @discardableResult func observeSingle(id: String) -> AnyPublisher<T?,Never>
    @discardableResult func observeList(predicate: NSPredicate) -> AnyPublisher<[T],Never>
    
    // Write
    func addOrUpdate(_ items: [T], chain: [()->()])
    func delete(_ items: [T], chain: [()->()])
    func replace(with items: [T], chain: [()->()])
}
