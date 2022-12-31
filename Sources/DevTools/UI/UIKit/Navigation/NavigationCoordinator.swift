//
//  NavigationCoordinator.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

public protocol NavigationCoordinator: AnyObject {
    typealias FreeCoodinatorClosure = (()->())?
    var children: [NavigationCoordinator] { get set }
    var router: RouterProtocol { get set }
    var onFree: FreeCoodinatorClosure { get set}
    func start()
}

extension NavigationCoordinator {
    func store(coordinator: NavigationCoordinator) {
        children.append(coordinator)
    }

    func free(coordinator: NavigationCoordinator) {
        children = children.filter { $0 !== coordinator }
        coordinator.onFree = nil
    }
}
