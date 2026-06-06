//
//  RuntimeLocalizedBarButtonItem.swift
//  
//
//  Created by Hardijs Ķirsis on 29/05/2023.
//

import Combine
import UIKit

open class RuntimeLocalizedBarButtonItem: UIBarButtonItem {
    
    // MARK: Properties
    
    public var localization: RuntimeLocalization = RuntimeStringFileLocalization.shared {
        didSet { observe() }
    }
    private var cancellable: AnyCancellable?
    
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
    @objc open func updateRuntimeLocalizedStrings() {
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
        cancellable = localization.observeCurrentLanguage()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateRuntimeLocalizedStrings() }
    }
}
