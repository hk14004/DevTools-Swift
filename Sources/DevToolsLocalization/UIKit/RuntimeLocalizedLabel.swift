//
//  RuntimeLocalizedLabel.swift
//
//
//  Created by Hardijs Ķirsis on 29/05/2023.
//

import Combine
import UIKit

open class RuntimeLocalizedLabel: UILabel {

    // MARK: Properties

    public var localization: RuntimeLocalization = RuntimeStringFileLocalization.shared {
        didSet { observe() }
    }

    @IBInspectable open var runtimeLocalizedKey: String? {
        didSet { updateRuntimeLocalizedStrings() }
    }

    open var runtimeLocalizedArguments: [CVarArg] = [] {
        didSet { updateRuntimeLocalizedStrings() }
    }

    private var cancellable: AnyCancellable?

    // MARK: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        updateRuntimeLocalizedStrings()
    }

    private func commonInit() {
        observe()
        updateRuntimeLocalizedStrings()
    }
}

// MARK: RuntimeLocalizedUIKitComponent

extension RuntimeLocalizedLabel: RuntimeLocalizedUIKitComponent {
    @objc open func updateRuntimeLocalizedStrings() {
        text = String(
            format: runtimeLocalizedKey?.runtimeLocalized() ?? "",
            locale: Locale.current,
            arguments: runtimeLocalizedArguments
        )
    }
}

// MARK: Private

extension RuntimeLocalizedLabel {
    private func observe() {
        cancellable = localization.observeCurrentLanguage()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateRuntimeLocalizedStrings() }
    }
}
