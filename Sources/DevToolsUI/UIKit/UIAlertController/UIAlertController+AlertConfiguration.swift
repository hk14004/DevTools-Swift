//
//  UIAlertController+AlertConfiguration.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import UIKit
import DevToolsCore

extension UIAlertController {
    public convenience init(configuration: AlertConfiguration) {
        let alertStyle = if UIDevice.current.userInterfaceIdiom == .pad {
            Style.alert
        } else {
            configuration.style
        }

        self.init(
            title: configuration.title,
            message: configuration.message,
            preferredStyle: alertStyle
        )

        for button in configuration.buttons {
            let action = UIAlertAction(
                title: button.title,
                style: button.style
            ) { _ in
                button.action()
            }
            action.accessibilityIdentifier = button.accessibilityIdentifier
            action.accessibilityLabel = button.accessibilityLabel
            if button.isSelected {
                action.setValue(button.isSelectedImage, forKey: "image")
            }

            addAction(action)
            if button.isPreferredAction {
                preferredAction = action
            }
        }
        view.accessibilityIdentifier = configuration.accessibilityId
    }
}
