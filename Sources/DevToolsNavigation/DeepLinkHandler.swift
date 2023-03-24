//
//  DeepLinkHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

public protocol DeepLinkHandler: AnyObject {
    func configure()
    func handleDeepLink(_ deepLink: URL, completionHandler: @escaping () -> ())
}
