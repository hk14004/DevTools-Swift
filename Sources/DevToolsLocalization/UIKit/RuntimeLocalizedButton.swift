//
//  LocalizedButton.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import UIKit

open class RuntimeLocalizedButton: UIButton {
    
    // MARK: Properties
    
    private let loc: RuntimeLocalization = RuntimeStringFileLocalization.shared
    
    @IBInspectable open var runtimeLocalizedKey: String? {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension RuntimeLocalizedButton: RuntimeLocalizedUIKitComponent {
    @objc func updateRuntimeLocalizedStrings() {
        guard titleLabel != nil else {
            return
        }
        setTitle(runtimeLocalizedKey?.localized(), for: .normal)
    }
}

// MARK: Private

extension RuntimeLocalizedButton {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateRuntimeLocalizedStrings))
    }
}
