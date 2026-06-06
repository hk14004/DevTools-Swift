//
//  UserDefault.swift
//

import Foundation

/// A property wrapper that reads and writes a value in `UserDefaults`,
/// eliminating the get/set boilerplate that every stored preference requires.
///
/// Supported value types are the same as `UserDefaults` itself: `Bool`, `Int`,
/// `Double`, `Float`, `String`, `Data`, `URL`, `Date`, `[Any]`, `[String: Any]`.
/// For custom types, encode to `Data` first and store that.
///
/// ```swift
/// // Before
/// var hasSeenOnboarding: Bool {
///     get { UserDefaults.standard.bool(forKey: "hasSeenOnboarding") }
///     set { UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding") }
/// }
///
/// // After
/// @UserDefault("hasSeenOnboarding", defaultValue: false)
/// var hasSeenOnboarding: Bool
///
/// // Custom store (e.g. App Group shared defaults)
/// @UserDefault("theme", defaultValue: "system", store: .appGroup)
/// var theme: String
/// ```
///
/// ## Using with a ViewModel
///
/// Because `@UserDefault` is a value-type wrapper it cannot directly trigger
/// `@Published` updates. Assign through a `@Published` property if Combine
/// observation is needed:
///
/// ```swift
/// final class SettingsViewModel: ObservableObject {
///     @Published var isDarkMode: Bool = Preferences.isDarkMode {
///         didSet { Preferences.isDarkMode = isDarkMode }
///     }
/// }
///
/// enum Preferences {
///     @UserDefault("isDarkMode", defaultValue: false)
///     static var isDarkMode: Bool
/// }
/// ```
@propertyWrapper
public struct UserDefault<T> {

    public let key: String
    public let defaultValue: T
    public let store: UserDefaults

    public init(_ key: String, defaultValue: T, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    public var wrappedValue: T {
        get { (store.object(forKey: key) as? T) ?? defaultValue }
        set { store.set(newValue, forKey: key) }
    }

    /// Exposes the wrapper itself — useful for inspecting `key`, `defaultValue`,
    /// or `store` from outside the declaration site.
    public var projectedValue: Self { self }
}
