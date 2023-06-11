//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionManaging {
    typealias CredentialID = String
    associatedtype UserSessionType: UserSessionCredentialsHolding where UserSessionType.CredentialsType == CredentialsStoreType.CredentialsType
    associatedtype CredentialsStoreType: UserSessionCredentialsManaging
    //    associatedtype UserSessionFactoryType: UserSessionFactory where UserSessionFactoryType.UserSessionType == UserSessionType
    
    var credentialsStore: CredentialsStoreType { get }
    var startedUserSessions: [CredentialID: UserSessionType] { get }
    var userSessionFactory: BaseUserSessionFactory<UserSessionType.CredentialsType> { get }
    
    func startAllUserSessions() // Starts all user sessions gotten from credential store
    func startUserSession(withCredentialsID id: String) // Create and hold instance
    func stopUserSession(forCredentialsID id: String) // Release instance
    func deleteUserSession(credentialsID: String) // Release instance, delete store
    func getStartedUserSession(forCredentialsID id: String) -> UserSessionType?
    func isSomebodyLoggedIn() -> Bool
    
}

open class BaseUserSessionManager<ConcreteCredentialsType: AuthorizationCredentials>: UserSessionManaging {
    
    // MARK: Types
    
    public typealias UserSessionType = BaseUserSession<ConcreteCredentialsType>
    public typealias CredentialsStoreType = BaseUserSessionCredentialsStore<ConcreteCredentialsType>
    
    // MARK: Properties
    
    public var credentialsStore: BaseUserSessionCredentialsStore<ConcreteCredentialsType>
    public var startedUserSessions: [CredentialID : BaseUserSession<ConcreteCredentialsType>]
    public var userSessionFactory: BaseUserSessionFactory<ConcreteCredentialsType>
    
    // MARK: Init
    
    public init(credentialsStore: BaseUserSessionCredentialsStore<ConcreteCredentialsType>, userSessionFactory: BaseUserSessionFactory<ConcreteCredentialsType>) {
        self.credentialsStore = credentialsStore
        self.userSessionFactory = userSessionFactory
        self.startedUserSessions = [:]
    }
    
    // MARK: UserSessionManager
    
    open func startAllUserSessions() {
        let creds = credentialsStore.getAllCredentials()
        creds.forEach { cred in
            let session = userSessionFactory.makeUserSession(with: cred)
            startedUserSessions[cred.id] = session
        }
    }
    
    open func startUserSession(with credentials: ConcreteCredentialsType) {
        let session = userSessionFactory.makeUserSession(with: credentials)
        startedUserSessions[credentials.id] = session
    }
    
    open func stopUserSession(forCredentialsID id: String) {
        startedUserSessions.removeValue(forKey: id)
    }
    
    open func deleteUserSession(credentialsID: String) {
        stopUserSession(forCredentialsID: credentialsID)
        credentialsStore.deleteCredentials(id: credentialsID)
    }
    
    open func getStartedUserSession(forCredentialsID id: String) -> BaseUserSession<ConcreteCredentialsType>? {
        return startedUserSessions[id]
    }
    
    open func isSomebodyLoggedIn() -> Bool {
        return !startedUserSessions.keys.isEmpty
    }
}
