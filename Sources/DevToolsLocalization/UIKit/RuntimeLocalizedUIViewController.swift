//
//  RuntimeLocalizedUIViewController.swift
//  
//
//  Created by Hardijs Ķirsis on 21/06/2023.
//

import UIKit

open class RuntimeLocalizedUIViewController: UIViewController {
    
    // MARK: Properties
    
    private let loc: RuntimeLocalization = RuntimeStringFileLocalization.shared
    
    @IBInspectable open var localizedStringKey: String? {
        didSet {
            updateLocalizedStrings()
        }
    }
    
    // MARK: Initialization
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Overridden Functions

    private func commonInit() {
        updateLocalizedStrings()
        observe()
    }
}

// MARK: LocalizedRuntimeComponent

extension RuntimeLocalizedUIViewController: RuntimeLocalizedUIKitComponent {
    @objc func updateLocalizedStrings() {
        title = localizedStringKey?.runtimeLocalized()
    }
}

// MARK: Private

extension RuntimeLocalizedUIViewController {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateLocalizedStrings))
    }
}
