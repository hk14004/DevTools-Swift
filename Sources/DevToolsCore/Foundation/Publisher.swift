//
//  Publisher.swift
//  
//
//  Created by Hardijs Ķirsis on 09/09/2023.
//

import Combine
import Foundation

public extension Publisher {
    func receiveOnMainThread() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        receive(on: DispatchQueue.main)
    }
}
