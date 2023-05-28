//
//  RuntimeLocalizedLabel.swift
//  
//
//  Created by Hardijs Ķirsis on 29/05/2023.
//


import UIKit

open class RuntimeLocalizedLabel: UILabel {
    
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

extension RuntimeLocalizedLabel: RuntimeLocalizedUIKitComponent {
    @objc func updateLocalizedStrings() {
        text = localizedStringKey?.localized()
    }
}

// MARK: Private

extension RuntimeLocalizedLabel {
    private func observe() {
        loc.observeLanguage(observer: self, selector: #selector(updateLocalizedStrings))
    }
}
