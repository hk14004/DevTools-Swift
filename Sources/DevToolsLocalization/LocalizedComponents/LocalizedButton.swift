//
//  LocalizedButton.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import UIKit

open class LocalizedButton: UIButton {
    
    //MARK: Properties
    
    private let runtimeLanguageInterface: RuntimeLanguageInterface = RuntimeLocalization.shared
    
    @IBInspectable open var stringsFileKey: String? {
        didSet {
            updateText()
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
        updateText()
    }
    
    private func commonInit() {
        updateText()
        observe()
    }
}

// MARK: LocalizedRuntimeComponent

extension LocalizedButton: LocalizedRuntimeComponent {
    @objc func updateText() {
        guard titleLabel != nil else {
            return
        }
        setTitle(stringsFileKey?.localized(), for: .normal)
    }
}

// MARK: Private

extension LocalizedButton {
    private func observe() {
        runtimeLanguageInterface.observeChange(observer: self, selector: #selector(updateText))
    }
}
