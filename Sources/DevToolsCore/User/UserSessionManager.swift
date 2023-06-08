//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionManager {
    associatedtype CredentialsType: AuthorizationCredentials
    associatedtype UserSessionType: UserSession
    
    func startup() // Start available user sessions
    
    // User session
    func startUserSession(_ userSession: UserSessionType) // Hold instance and store something in keychain
    func stopUserSession(_ userSession: UserSessionType) // Release stored instance
    func getStartedUserSession(credentialsID id: String) -> UserSessionType?
    func isSomebodyLoggedIn() -> Bool
    
    // Credentials
    func storeCredentials(_ credentials: CredentialsType)
    func getCredentials(id: String) -> CredentialsType?
    func deleteCredentials(id: String)
}
