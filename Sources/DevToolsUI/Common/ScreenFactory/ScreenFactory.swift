//
//  ScreenFactory.swift
//  
//
//  Created by Hardijs Ķirsis on 01/09/2023.
//

import Foundation

protocol ScreenFactory {
    associatedtype ScreenType
    func make() -> ScreenType
}
