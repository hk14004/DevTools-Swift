//
//  Validator.swift
//  
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import Foundation

/// A composable validation rule for any input type.
///
/// Conforming types return an array of human-readable error messages.
/// An empty array means the input is valid.
///
/// ```swift
/// struct NonEmptyValidator: Validator {
///     func validate(_ input: String) -> [String] {
///         input.isBlank ? ["Field is required"] : []
///     }
/// }
///
/// struct RangeValidator: Validator {
///     func validate(_ input: Int) -> [String] {
///         (1...120).contains(input) ? [] : ["Age must be between 1 and 120"]
///     }
/// }
///
/// // Compose validators
/// let errors = [NonEmptyValidator(), MinLengthValidator(6)]
///     .flatMap { $0.validate(username) }
/// ```
public protocol Validator<Input> {
    associatedtype Input
    func validate(_ input: Input) -> [String]
}

#if DEBUG
private struct LoginUsernameValidatorExample: Validator {
    func validate(_ input: String) -> [String] {
        var errors: [String] = []
        if input.isBlank        { errors.append("Username is required") }
        if input.count < 6      { errors.append("Username must be at least 6 characters") }
        return errors
    }
}
#endif
