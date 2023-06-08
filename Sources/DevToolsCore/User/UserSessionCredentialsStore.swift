//
//  AuthorizationCredentialsStore.swift
//  
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

public protocol UserSessionCredentialsStore {
    associatedtype CredentialsType: AuthorizationCredentials
    func storeCredentials(_ credentials: CredentialsType)
    func getCredentials(id: String) -> CredentialsType?
    func getAllCredentials() -> [CredentialsType]
    func deleteCredentials(id: String)
    func deleteAllCredentials()
}
