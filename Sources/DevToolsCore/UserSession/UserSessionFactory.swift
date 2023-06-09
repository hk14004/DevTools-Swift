//
//  BaseUserSessionFactory.swift
//  
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

public protocol UserSessionFactory {
    func makeUserSession<T: AuthorizationCredentials>(with credentials: T) -> BaseUserSession<T>
}
