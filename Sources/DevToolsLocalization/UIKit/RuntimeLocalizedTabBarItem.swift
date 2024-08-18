//
//  RuntimeLocalizedTabBarItem.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import UIKit

open class RuntimeLocalizedTabBarItem: UITabBarItem {
    
    // MARK: Properties
    
    private let loc: RuntimeLocalization = RuntimeStringFileLocalization.shared
    
    @IBInspectable open var runtimeLocalizedKey: String? {
        didSet {
            updateRuntimeLocalizedStrings()
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
        updateRuntimeLocalizedStrings()
    }
    
    private func commonInit() {
        updateRuntimeLocalizedStrings()
        observe()
    }
    
}

// MARK: LocalizedRuntimeComponent

extension RuntimeLocalizedTabBarItem: RuntimeLocalizedUIKitComponent {
    @objc func updateRuntimeLocalizedStrings() {
        title = runtimeLocalizedKey?.localized()
    }
}

// MARK: Private

extension RuntimeLocalizedTabBarItem {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateRuntimeLocalizedStrings))
    }
}
