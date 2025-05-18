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
    
    @IBInspectable open var runtimeLocalizedTitleKey: String? {
        didSet {
            updateRuntimeLocalizedStrings()
        }
    }
    
    open var runtimeLocalizedArguments: [CVarArg] = [] {
        didSet {
            updateRuntimeLocalizedStrings()
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
    
    // MARK: Private

    private func commonInit() {
        updateRuntimeLocalizedStrings()
        observe()
    }
    
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateRuntimeLocalizedStrings))
    }
    
    // MARK: Public
    
    @objc open func updateRuntimeLocalizedStrings() {
        title = String(
            format: runtimeLocalizedTitleKey?.runtimeLocalized() ?? "",
            locale: Locale.current,
            arguments: runtimeLocalizedArguments
        )
    }
}
