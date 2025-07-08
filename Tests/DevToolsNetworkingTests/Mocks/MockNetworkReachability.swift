//
//  NetworkReachability.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 08/07/2025.
//

import Foundation
import DevToolsNetworking
import Combine

struct MockNetworkReachability: NetworkReachability {
    var isReachable: Bool
    
    func trackIsReachable() -> AnyPublisher<Bool, Never> {
        .just(isReachable)
    }
}
