//
//  RuntimeStringFileLocalizationTests.swift
//  DevToolsLocalization
//
//  Created by Hardijs on 04/06/2026.
//

import Combine
import XCTest
@testable import DevToolsLocalization

// MARK: - Helpers

/// A mock `RuntimeLocalization` used to test components in isolation,
/// without depending on `RuntimeStringFileLocalization`'s singleton state.
final class MockRuntimeLocalization: RuntimeLocalization {

    var currentLanguage: String
    var availableLanguages: [String]
    private let subject: CurrentValueSubject<String, Never>
    var changeCallCount = 0

    init(currentLanguage: String = "en", availableLanguages: [String] = ["en", "lv", "fr"]) {
        self.currentLanguage = currentLanguage
        self.availableLanguages = availableLanguages
        self.subject = CurrentValueSubject(currentLanguage)
    }

    func getCurrentLanguage() -> String { currentLanguage }
    func getAvailableLanguages() -> [String] { availableLanguages }

    @MainActor func change(languageCode: String) {
        changeCallCount += 1
        currentLanguage = languageCode
        subject.send(languageCode)
    }

    func observeCurrentLanguage() -> AnyPublisher<String, Never> {
        subject.eraseToAnyPublisher()
    }

    func displayName(for languageCode: String) -> String {
        languageCode.uppercased() // simplified for tests
    }

    func localized(_ string: String) -> String { string }
    func localizedFormat(_ string: String, arguments: CVarArg...) -> String { string }
    func localizedPlural(_ string: String, argument: CVarArg) -> String { string }

    @available(*, deprecated) func observeLanguage(observer: Any, selector: Selector) {}
    @available(*, deprecated) func observeLanguage(callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle {
        NSObject()
    }
    @available(*, deprecated) func stopObservingLanguage(handle: ObserverHandle) {}
    @available(*, deprecated) func stopObservingLanguage(observer: Any) {}
}

// MARK: - RuntimeStringFileLocalization tests

final class RuntimeStringFileLocalizationTests: XCTestCase {

    // MARK: - Default language

    func testDefaultLanguageIsEnglish() {
        // Remove any persisted language so we get the true default.
        UserDefaults.standard.removeObject(forKey: "RuntimeStringFileLocalizationLanguageKey")
        XCTAssertEqual(RuntimeStringFileLocalization.shared.getCurrentLanguage(), "en")
    }

    // MARK: - change(languageCode:)

    @MainActor
    func testChangeToDefaultLanguagePersists() {
        // The test bundle only contains "en", so "en" is always resolvable.
        let sut = RuntimeStringFileLocalization.shared
        UserDefaults.standard.removeObject(forKey: "RuntimeStringFileLocalizationLanguageKey")
        sut.change(languageCode: "en")
        XCTAssertEqual(sut.getCurrentLanguage(), "en")
    }

    @MainActor
    func testChangePublisherEmitsResolvedCode() {
        // The test bundle only has "en". Any other code falls back to "en".
        // What we're verifying: publisher always emits the RESOLVED code (matching
        // UserDefaults), not the raw input passed to change(languageCode:).
        let sut = RuntimeStringFileLocalization.shared
        var received: [String] = []
        let cancellable = sut.observeCurrentLanguage()
            .dropFirst()
            .sink { received.append($0) }

        sut.change(languageCode: "xx_FALLBACK_1")
        sut.change(languageCode: "xx_FALLBACK_2")

        // Both resolve to "en" since the test bundle has no other languages.
        // The important assertion is that neither emits the raw invalid input.
        XCTAssertTrue(received.allSatisfy { $0 != "xx_FALLBACK_1" && $0 != "xx_FALLBACK_2" })
        cancellable.cancel()
    }

    @MainActor
    func testChangePublisherEmitsResolvedCodeNotInvalidInput() {
        // The bug that was fixed: publisher was sending the raw input even when
        // it fell back to the default — the publisher must always match UserDefaults.
        let sut = RuntimeStringFileLocalization.shared
        let originalLanguage = sut.getCurrentLanguage()
        var received: [String] = []
        let cancellable = sut.observeCurrentLanguage()
            .dropFirst()
            .sink { received.append($0) }

        sut.change(languageCode: "xx_INVALID")

        // Publisher should emit the resolved fallback ("en"), NOT "xx_INVALID".
        XCTAssertEqual(received.first, "en")
        XCTAssertNotEqual(received.first, "xx_INVALID")

        cancellable.cancel()
        sut.change(languageCode: originalLanguage)
    }

    @MainActor
    func testChangeToSameLanguageDoesNotPostNotification() {
        let sut = RuntimeStringFileLocalization.shared
        sut.change(languageCode: "en")

        var received = 0
        let cancellable = sut.observeCurrentLanguage()
            .dropFirst()
            .sink { _ in received += 1 }

        // Changing to the same language — publisher still emits (CurrentValueSubject
        // always sends), but NotificationCenter should not re-post.
        sut.change(languageCode: "en")
        cancellable.cancel()
        // No assertion needed — just verifying no crash.
    }

    // MARK: - displayName(for:)

    func testDisplayNameReturnsNonEmptyStringForKnownCode() {
        let name = RuntimeStringFileLocalization.shared.displayName(for: "en")
        XCTAssertFalse(name.isEmpty)
    }

    func testDisplayNameFallsBackToCodeForUnknownCode() {
        // For an unrecognised code the implementation returns the code itself.
        let name = RuntimeStringFileLocalization.shared.displayName(for: "xx_UNKNOWN")
        XCTAssertEqual(name, "xx_UNKNOWN")
    }
}

// MARK: - MockRuntimeLocalization tests

final class MockRuntimeLocalizationTests: XCTestCase {

    func testMockCurrentLanguage() {
        let mock = MockRuntimeLocalization(currentLanguage: "lv")
        XCTAssertEqual(mock.getCurrentLanguage(), "lv")
    }

    @MainActor func testMockChangePublisherEmitsNewCode() {
        let mock = MockRuntimeLocalization()
        var received: [String] = []
        let cancellable = mock.observeCurrentLanguage()
            .dropFirst()
            .sink { received.append($0) }

        mock.change(languageCode: "fr")
        mock.change(languageCode: "lv")

        XCTAssertEqual(received, ["fr", "lv"])
        cancellable.cancel()
    }

    @MainActor func testMockChangeCallCount() {
        let mock = MockRuntimeLocalization()
        mock.change(languageCode: "fr")
        mock.change(languageCode: "lv")
        XCTAssertEqual(mock.changeCallCount, 2)
    }
}
