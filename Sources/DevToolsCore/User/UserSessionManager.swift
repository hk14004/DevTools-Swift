//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionManager {
    
    associatedtype UserSessionType: UserSession where UserSessionType.CredentialsType == CredentialsStoreType.CredentialsType
    associatedtype CredentialsStoreType: UserSessionCredentialsStore
    associatedtype UserSessionFactoryType: UserSessionFactory where UserSessionFactoryType.UserSessionType == UserSessionType
    
    var credentialsStore: CredentialsStoreType { get }
    var userSessionFactory: UserSessionFactoryType { get }
    
    func startAllUserSessions() // Starts all user sessions gotten from credential store
    func startUserSession(withCredentialsID id: String) // Create and hold instance
    func stopUserSession(forCredentialsID id: String) // Release instance
    func deleteUserSession(credentialsID: String) // Release instance, delete store
    func getStartedUserSession(forCredentialsID id: String) -> UserSessionType?
    func isSomebodyLoggedIn() -> Bool
    
}
