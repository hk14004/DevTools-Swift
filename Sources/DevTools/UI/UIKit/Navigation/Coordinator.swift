//
//  Coordinator.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

public protocol Coordinator: AnyObject {
    typealias FreeCoodinatorClosure = (()->())?
    var children: [Coordinator] { get set }
    var router: RouterProtocol { get set }
    var onFree: FreeCoodinatorClosure { get set}
    func start()
}

extension Coordinator {
    func store(coordinator: Coordinator) {
        children.append(coordinator)
    }

    func free(coordinator: Coordinator) {
        children = children.filter { $0 !== coordinator }
        coordinator.onFree = nil
    }
}
