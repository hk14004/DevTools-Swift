//
//  NetworkReachability.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 07/07/2025.
//

import Reachability
import Combine

public protocol NetworkReachability {
    var isReachable: Bool { get }
    func trackIsReachable() -> AnyPublisher<Bool, Never>
}

public class DefaultNetworkReachability: NetworkReachability {
    public var isReachable: Bool {
        isReachableSubject.value
    }
    
    // MARK: Properties
    private var reachability: Reachability?
    private var isReachableSubject = CurrentValueSubject<Bool, Never>(true)
    
    // MARK: LifeCycle
    public init() {
        reachability = try? Reachability()
        try? reachability?.startNotifier()
        reachability?.whenReachable = { [weak self] _ in
            guard let self, !isReachableSubject.value else { return }
            isReachableSubject.send(true)
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            guard let self, isReachableSubject.value else { return }
            isReachableSubject.send(false)
        }
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    // MARK: Methods
    public func trackIsReachable() -> AnyPublisher<Bool, Never> {
        isReachableSubject.eraseToAnyPublisher()
    }
}
