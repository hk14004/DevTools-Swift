//
//  UIViewController + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 12/06/2023.
//

import UIKit

public extension UIViewController {
    static func getTopViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?.windows
            .first(where: { $0.isKeyWindow })
            else {
                return nil
            }
        var top = keyWindow.rootViewController
        while let next = top?.presentedViewController {
            top = next
        }
        return top
    }
}
