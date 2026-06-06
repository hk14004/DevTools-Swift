//
//  AuthorizationCredentials.swift
//
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

public protocol AuthorizationCredentials {
    associatedtype AuthData // May hold token and other related data
    var id: String { get }
    var authorizationData: AuthData { get }
}

public protocol UserSessionCredentialsStore {
    associatedtype CredentialsType: AuthorizationCredentials
    func storeCredentials(_ credentials: CredentialsType)
    func getCredentials(id: String) -> CredentialsType?
    func getAllCredentials() -> [CredentialsType]
    func deleteCredentials(id: String)
    func deleteAllCredentials()
}
