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
    
    @IBInspectable open var runtimeLocalizedKey: String? {
        didSet {
            updateRuntimeLocalizedStrings()
        }
    }
    open var runtimeLocalizedArguments: [CVarArg] = [] {
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

extension RuntimeLocalizedBarButtonItem: RuntimeLocalizedUIKitComponent {
    @objc func updateRuntimeLocalizedStrings() {
        title = String(
            format: runtimeLocalizedKey?.runtimeLocalized() ?? "",
            locale: Locale.current,
            arguments: runtimeLocalizedArguments
        )
    }
}

// MARK: Private

extension RuntimeLocalizedBarButtonItem {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateRuntimeLocalizedStrings))
    }
}
