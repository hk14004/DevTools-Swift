//
//  AuthorizedUserSessionHandler.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol AuthorizedUserSessionManagerProtocol {
    associatedtype T: AuthorizedEntityProtocol
    associatedtype U: AuthorizedUserSessionProtocol
    
    func configure()
    func startAuthorizedUserSession(_ userSession: U) // Hold instance and store something in keychain
    func stopAuthorizedUserSession(_ userSession: U) // Release stored instance
    func getStartedAuthorizedUserSession(forEntity entity: T) -> U?
    func isSomebodyLoggedIn() -> Bool
    func storeAuthorizedEntity(entity: T)
    func getAuthorizedEntity(id: String) -> T
    func deleteAuthorizedEntity(id: String) -> T
}
