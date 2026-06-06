//
//  RuntimeLocalizedUIViewController.swift
//
//
//  Created by Hardijs Ķirsis on 21/06/2023.
//

import Combine
import UIKit

open class RuntimeLocalizedUIViewController: UIViewController {

    // MARK: Properties

    public var localization: RuntimeLocalization = RuntimeStringFileLocalization.shared {
        didSet { observe() }
    }

    @IBInspectable open var runtimeLocalizedTitleKey: String? {
        didSet { updateRuntimeLocalizedStrings() }
    }

    open var runtimeLocalizedArguments: [CVarArg] = [] {
        didSet { updateRuntimeLocalizedStrings() }
    }

    private var cancellable: AnyCancellable?

    // MARK: Initialization

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Public

    @objc open func updateRuntimeLocalizedStrings() {
        title = String(
            format: runtimeLocalizedTitleKey?.runtimeLocalized() ?? "",
            locale: Locale.current,
            arguments: runtimeLocalizedArguments
        )
    }

    // MARK: Private

    private func commonInit() {
        observe()
        updateRuntimeLocalizedStrings()
    }

    private func observe() {
        cancellable = localization.observeCurrentLanguage()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateRuntimeLocalizedStrings() }
    }
}
