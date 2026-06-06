//
//  RuntimeLocalizationObserver.swift
//
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Combine
import SwiftUI

/// An `@Observable` object that triggers SwiftUI view updates when the app language changes.
///
/// Add this to any view that displays localised strings so it re-renders automatically
/// when `RuntimeStringFileLocalization.change(languageCode:)` is called.
///
/// ```swift
/// struct ContentView: View {
///     @State private var observer = RuntimeLocalizationObserver()
///
///     var body: some View {
///         Text("greeting".runtimeLocalized())
///             .id(observer.languageCode) // forces re-render on language change
///     }
/// }
/// ```
///
/// Pass `animate: true` to wrap the language change in a SwiftUI animation:
/// ```swift
/// @State private var observer = RuntimeLocalizationObserver(animate: true)
/// ```
@Observable
public final class RuntimeLocalizationObserver {

    public private(set) var languageCode: LanguageCode

    private let animate: Bool
    private var cancellable: AnyCancellable?

    public init(
        animate: Bool = false,
        localization: RuntimeLocalization = RuntimeStringFileLocalization.shared
    ) {
        self.animate = animate
        self.languageCode = localization.getCurrentLanguage()

        cancellable = localization.observeCurrentLanguage()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] code in
                guard let self else { return }
                if animate {
                    withAnimation { self.languageCode = code }
                } else {
                    self.languageCode = code
                }
            }
    }
}
