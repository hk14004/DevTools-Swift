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
            Style(rawValue: configuration.style.rawValue) ?? .alert
        }

        self.init(
            title: configuration.title,
            message: configuration.message,
            preferredStyle: alertStyle
        )

        for button in configuration.buttons {
            let action = UIAlertAction(
                title: button.title,
                style: UIAlertAction.Style.init(rawValue: button.style.rawValue) ?? .default
            ) { _ in
                button.action()
            }
            action.accessibilityIdentifier = button.accessibilityIdentifier
            action.accessibilityLabel = button.accessibilityLabel
            if button.isSelected, let data = button.selectedImageData {
                action.setValue(UIImage(data: data), forKey: "image")
            }

            addAction(action)
            if button.isPreferredAction {
                preferredAction = action
            }
        }
        view.accessibilityIdentifier = configuration.accessibilityId
    }
}
