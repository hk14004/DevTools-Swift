//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionManaging {
    
    associatedtype UserSessionType: UserSessionCredentialsHolding where UserSessionType.CredentialsType == CredentialsStoreType.CredentialsType
    associatedtype CredentialsStoreType: UserSessionCredentialsManaging
//    associatedtype UserSessionFactoryType: UserSessionFactory where UserSessionFactoryType.UserSessionType == UserSessionType
    
    var credentialsStore: CredentialsStoreType { get }
//    var userSessionFactory: UserSessionFactoryType { get }
    
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
    
    // MARK: Init
    
    public init(credentialsStore: BaseUserSessionCredentialsStore<ConcreteCredentialsType>) {
        self.credentialsStore = credentialsStore
    }
    
    // MARK: UserSessionManager
    
    public func startAllUserSessions() {
        fatalError("implement")
    }
    
    public func startUserSession(withCredentialsID id: String) {
        fatalError("implement")
    }
    
    public func stopUserSession(forCredentialsID id: String) {
        fatalError("implement")
    }
    
    public func deleteUserSession(credentialsID: String) {
        fatalError("implement")
    }
    
    public func getStartedUserSession(forCredentialsID id: String) -> BaseUserSession<ConcreteCredentialsType>? {
        fatalError("implement")
    }
    
    public func isSomebodyLoggedIn() -> Bool {
        fatalError("implement")
    }
}
