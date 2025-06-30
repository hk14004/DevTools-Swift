//
//  Validator.swift
//  
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import Foundation

public protocol Validator {
    typealias ErrorMessage = String
    func validate(_ input: String) -> [ErrorMessage]
}

fileprivate class LoginUsernameValidatorExample: Validator {
    func validate(_ input: String) -> [ErrorMessage] {
        var errors: [String] = []

        // Perform validation logic specific to the username field
        // Append error messages to the `errors` array if the input is invalid
        
        if input.isEmpty {
            errors.append("Username is required")
        }
        
        if input.count < 6 {
            errors.append("Username should be at least 6 characters")
        }
        
        // Add more validation rules as needed
        
        return errors
    }
}
