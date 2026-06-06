//
//  Validator.swift
//  
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import Foundation

// MARK: - ValidationRule

/// A single validation rule — pure logic with no message attached.
///
/// Rules are reusable across fields. The message is supplied at the
/// `FieldValidator` level where field context is known.
///
/// ```swift
/// // Same rule, different message per field
/// .nonEmpty.withMessage("Email is required")
/// .nonEmpty.withMessage("Password is required")
/// .minLength(8).withMessage("Password must be at least 8 characters")
/// ```
public struct ValidationRule<Input> {
    public let isSatisfied: (Input) -> Bool

    public init(_ isSatisfied: @escaping (Input) -> Bool) {
        self.isSatisfied = isSatisfied
    }
}

// MARK: - ValidationCheck

/// A rule paired with the error message to show when it fails.
///
/// Create via `rule.withMessage("...")` rather than directly.
public struct ValidationCheck<Input> {
    public let rule: ValidationRule<Input>
    public let errorMessage: String

    public init(rule: ValidationRule<Input>, errorMessage: String) {
        self.rule = rule
        self.errorMessage = errorMessage
    }

    /// Returns `nil` if the input satisfies the rule, or `errorMessage` if not.
    public func validate(_ input: Input) -> String? {
        rule.isSatisfied(input) ? nil : errorMessage
    }
}

public extension ValidationRule {
    /// Binds a contextual message to this rule, producing a `ValidationCheck`.
    ///
    /// ```swift
    /// .nonEmpty.withMessage("Email is required")
    /// .minLength(8).withMessage("Password must be at least 8 characters")
    /// ```
    func withMessage(_ message: String) -> ValidationCheck<Input> {
        ValidationCheck(rule: self, errorMessage: message)
    }
}

// MARK: - FieldValidator

/// Composes multiple `ValidationCheck`s for a single input field.
///
/// ## Usage in a ViewModel
///
/// ```swift
/// private let emailValidator = FieldValidator<String>(
///     .nonEmpty.withMessage("Email is required"),
///     .validEmail.withMessage("Please enter a valid email")
/// )
///
/// private let passwordValidator = FieldValidator<String>(
///     .nonEmpty.withMessage("Password is required"),
///     .minLength(8).withMessage("Password must be at least 8 characters")
/// )
///
/// // Inline hint while typing (first error only)
/// var emailError: AnyPublisher<String?, Never> {
///     $email
///         .map { [weak self] in self?.emailValidator.firstError(for: $0) }
///         .eraseToAnyPublisher()
/// }
///
/// // Enable submit when all fields pass
/// var isFormValid: AnyPublisher<Bool, Never> {
///     Publishers.CombineLatest($email, $password)
///         .map { [weak self] email, pass in
///             guard let self else { return false }
///             return emailValidator.isValid(email) && passwordValidator.isValid(pass)
///         }
///         .eraseToAnyPublisher()
/// }
/// ```
public struct FieldValidator<Input> {
    public let checks: [ValidationCheck<Input>]

    public init(_ checks: ValidationCheck<Input>...) {
        self.checks = checks
    }

    public init(checks: [ValidationCheck<Input>]) {
        self.checks = checks
    }

    /// All failing error messages — useful for showing a full list of requirements.
    public func errors(for input: Input) -> [String] {
        checks.compactMap { $0.validate(input) }
    }

    /// The first failing error message — useful for inline field hints while typing.
    public func firstError(for input: Input) -> String? {
        checks.lazy.compactMap { $0.validate(input) }.first
    }

    /// `true` if the input satisfies every check.
    public func isValid(_ input: Input) -> Bool {
        checks.allSatisfy { $0.validate(input) == nil }
    }
}

// MARK: - Built-in String rules

public extension ValidationRule where Input == String {

    /// Passes when the string is not blank (not empty or whitespace-only).
    static var nonEmpty: Self { .init { !$0.isBlank } }

    /// Passes when the string is a valid email address.
    static var validEmail: Self { .init { $0.isEmailAddress() } }

    /// Passes when the string contains at least `n` characters.
    static func minLength(_ n: Int) -> Self { .init { $0.count >= n } }

    /// Passes when the string contains at most `n` characters.
    static func maxLength(_ n: Int) -> Self { .init { $0.count <= n } }

    /// Passes when the string matches the given regex pattern.
    /// Returns `false` (invalid) if the pattern itself is malformed.
    static func matching(_ pattern: String) -> Self {
        .init {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
            let range = NSRange($0.startIndex..., in: $0)
            return regex.firstMatch(in: $0, range: range) != nil
        }
    }

    /// Passes when the string exactly equals `value`.
    /// Useful for password confirmation fields.
    static func equals(_ value: String) -> Self { .init { $0 == value } }
}

// MARK: - Built-in Comparable rules

public extension ValidationRule where Input: Comparable {

    /// Passes when the value falls within `range`.
    static func inRange(_ range: ClosedRange<Input>) -> Self { .init { range.contains($0) } }

    /// Passes when the value is greater than or equal to `minimum`.
    static func min(_ minimum: Input) -> Self { .init { $0 >= minimum } }

    /// Passes when the value is less than or equal to `maximum`.
    static func max(_ maximum: Input) -> Self { .init { $0 <= maximum } }
}
