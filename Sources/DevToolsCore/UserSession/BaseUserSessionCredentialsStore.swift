//
//  AuthorizationCredentialsStore.swift
//  
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

public protocol UserSessionCredentialsManaging {
    associatedtype CredentialsType: AuthorizationCredentials
    func storeCredentials(_ credentials: CredentialsType)
    func getCredentials(id: String) -> CredentialsType?
    func getAllCredentials() -> [CredentialsType]
    func deleteCredentials(id: String)
    func deleteAllCredentials()
}

open class BaseUserSessionCredentialsStore<ConcreteCredentialType: AuthorizationCredentials>: UserSessionCredentialsManaging  {
    public func storeCredentials(_ credentials: ConcreteCredentialType) {
        fatalError("implement")
    }
    
    public func getCredentials(id: String) -> ConcreteCredentialType? {
        fatalError("implement")
    }
    
    public func getAllCredentials() -> [ConcreteCredentialType] {
        fatalError("implement")
    }
    
    public func deleteCredentials(id: String) {
        fatalError("implement")
    }
    
    public func deleteAllCredentials() {
        fatalError("implement")
    }
}
