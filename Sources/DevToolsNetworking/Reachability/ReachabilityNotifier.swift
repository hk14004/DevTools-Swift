//
//  ReachabilityNotifier.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 07/07/2025.
//

import Reachability
import Combine

public protocol ReachabilityNotifier {
    var isReachable: CurrentValueSubject<Bool, Never> { get }
}

public class DefaultReachabilityNotifier: ReachabilityNotifier {
    // MARK: Properties
    private var reachability: Reachability?
    public var isReachable = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: LifeCycle
    init() {
        reachability = try? Reachability()
        reachability?.whenReachable = { [weak self] _ in
            guard let self, !isReachable.value else { return }
            isReachable.send(true)
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            guard let self, isReachable.value else { return }
            isReachable.send(false)
        }
    }
}
