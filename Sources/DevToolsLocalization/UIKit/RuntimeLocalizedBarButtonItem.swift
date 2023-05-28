//
//  RuntimeLocalizedBarButtonItem.swift
//  
//
//  Created by Hardijs Ķirsis on 29/05/2023.
//

import UIKit

open class RuntimeLocalizedBarButtonItem: UIBarButtonItem {
    
    // MARK: Properties
    
    private let loc: RuntimeLocalization = RuntimeStringFileLocalization.shared
    
    @IBInspectable open var localizedStringKey: String? {
        didSet {
            updateLocalizedStrings()
        }
    }
    
    //MARK: Initialization
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Overridden Functions
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        updateLocalizedStrings()
    }
    
    private func commonInit() {
        updateLocalizedStrings()
        observe()
    }
    
}

// MARK: LocalizedRuntimeComponent

extension RuntimeLocalizedBarButtonItem: RuntimeLocalizedUIKitComponent {
    @objc func updateLocalizedStrings() {
        title = localizedStringKey?.localized()
    }
}

// MARK: Private

extension RuntimeLocalizedBarButtonItem {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateLocalizedStrings))
    }
}
