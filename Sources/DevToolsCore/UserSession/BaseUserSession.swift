//
//  BaseUserSession.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

open class BaseUserSession<ConcreteCredentialType: AuthorizationCredentials>: UserSessionCredentialsHolding {
    public var credentials: ConcreteCredentialType
    
    public init(credentials: ConcreteCredentialType) {
        self.credentials = credentials
    }
}

public protocol UserSessionCredentialsHolding {
    associatedtype CredentialsType: AuthorizationCredentials
    var credentials: CredentialsType { get }
}

public protocol AuthorizationCredentials {
    associatedtype AuthData // May hold token and other related data
    var id: String { get }
    var authorizationData: AuthData { get }
}
