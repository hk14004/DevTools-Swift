//
//  LocalizedButton.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import UIKit

open class RuntimeLocalizedTextField: UITextField {
    
    // MARK: Properties
    
    private let loc: RuntimeLocalization = RuntimeStringFileLocalization.shared
    
    @IBInspectable open var localizedStringKey: String? {
        didSet {
            updateLocalizedStrings()
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
        updateLocalizedStrings()
    }
    
    private func commonInit() {
        updateLocalizedStrings()
        observe()
    }
}

// MARK: LocalizedRuntimeComponent

extension RuntimeLocalizedTextField: RuntimeLocalizedUIKitComponent {
    @objc func updateLocalizedStrings() {
        placeholder = localizedStringKey?.localized()
    }
}

// MARK: Private

extension RuntimeLocalizedTextField {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateLocalizedStrings))
    }
}
