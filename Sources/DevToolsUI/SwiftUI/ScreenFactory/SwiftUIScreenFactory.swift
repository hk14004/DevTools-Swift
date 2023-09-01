//
//  SwiftUIScreenFactory.swift
//  
//
//  Created by Hardijs Ķirsis on 01/09/2023.
//

import SwiftUI

public protocol SwiftUIScreenFactory: ScreenFactory where ScreenType == any View {}
