//
//  BaseUserSessionFactory.swift
//  
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

open class BaseUserSessionFactory<T: AuthorizationCredentials> {
    
    public init() {}
    
    public func makeUserSession(with credentials: T) -> BaseUserSession<T> {
        BaseUserSession(credentials: credentials)
    }
}
