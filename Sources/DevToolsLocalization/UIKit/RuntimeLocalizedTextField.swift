//
//  RuntimeLocalizedTextField.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Combine
import UIKit

open class RuntimeLocalizedTextField: UITextField {
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
       commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    //MARK: Overridden Functions
    
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

extension RuntimeLocalizedTextField: RuntimeLocalizedUIKitComponent {
    @objc open func updateRuntimeLocalizedStrings() {
        placeholder = String(
            format: runtimeLocalizedKey?.runtimeLocalized() ?? "",
            locale: Locale.current,
            arguments: runtimeLocalizedArguments
        )
    }
}

// MARK: Private

extension RuntimeLocalizedTextField {
    private func observe() {
        cancellable = localization.observeCurrentLanguage()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateRuntimeLocalizedStrings() }
    }
}
