//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol AuthorizedUserSessionManager {
    associatedtype T: AuthorizationCredentials
    associatedtype U: UserSession
    
    func startup() // Start available user sessions
    
    // User session
    func startUserSession(_ userSession: U) // Hold instance and store something in keychain
    func stopUserSession(_ userSession: U) // Release stored instance
    func getStartedUserSession(credentialsID id: String) -> U?
    func isSomebodyLoggedIn() -> Bool
    
    // Credentials
    func storeCredentials(_ credentials: T)
    func getCredentials(id: String) -> T?
    func deleteCredentials(id: String)
}
