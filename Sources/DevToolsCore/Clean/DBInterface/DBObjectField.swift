//
//  DBObjectField.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 25/06/2025.
//

import Foundation

public protocol DBObjectField: CaseIterable, Hashable {}

extension DBObjectField {
    public static func getSetOfAllFields() -> Set<Self> {
        Set(Self.allCases)
    }
}
