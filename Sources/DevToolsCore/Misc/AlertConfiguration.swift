//
//  AlertConfiguration.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import Foundation

public struct AlertConfiguration {
    // MARK: Variables
    public let title: String
    public let message: String
    public let buttons: [Button]
    public let style: Style
    public let accessibilityId: String?
    public let accessibilityLabel: String?
    
    // MARK: - Lifecycle
    public init(
        title: String = "",
        message: String = "",
        buttons: [Button] = [],
        style: Style = .alert,
        accessibilityId: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.style = style
        self.accessibilityId = accessibilityId
        self.accessibilityLabel = accessibilityLabel
    }
}

extension AlertConfiguration {
    public struct Button {
        // MARK: Variables
        public let title: String
        public let action: VoidCallback
        public let style: AlertAction.Style
        public let isPreferredAction: Bool
        public let isSelected: Bool
        public let selectedImageData: Data?
        public let accessibilityIdentifier: String?
        public let accessibilityLabel: String?
        
        // MARK: - Lifecycle
        public init(
            title: String,
            action: @escaping VoidCallback,
            style: AlertAction.Style = .default,
            isPreferredAction: Bool = false,
            isSelected: Bool = false,
            selectedImageData: Data? = nil,
            accessibilityIdentifier: String? = nil,
            accessibilityLabel: String? = nil
        ) {
            self.title = title
            self.action = action
            self.style = style
            self.isPreferredAction = isPreferredAction
            self.isSelected = isSelected
            self.selectedImageData = selectedImageData
            self.accessibilityIdentifier = accessibilityIdentifier
            self.accessibilityLabel = accessibilityLabel
        }
    }
}

public extension AlertConfiguration {
    enum Style: Int {
        case actionSheet = 0
        case alert
    }
    
    struct AlertAction {
        public enum Style: Int {
            case `default` = 0
            case cancel
            case destructive
        }
    }
}
