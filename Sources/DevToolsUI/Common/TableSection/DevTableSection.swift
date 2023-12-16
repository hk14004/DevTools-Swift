//
//  UISectionModel.swift
//
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation
import DevToolsCore

public protocol DevTableSection {
    associatedtype Cell: Hashable
    associatedtype Identifier: CaseIterable, RawRepresentable, Hashable where Identifier.RawValue == String
    
    var identifier: Identifier { get }
    var title: String { get set }
    var cells: [Cell] { get set}
}
