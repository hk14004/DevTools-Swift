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

class SwedbankUserSessionCredentialsStore: UserSessionCredentialsStore {
    func storeCredentials(_ credentials: SwedbankCredentials) {
            
    }
    
    func getCredentials(id: String) -> SwedbankCredentials? {
        nil
    }
    
    func getAllCredentials() -> [SwedbankCredentials] {
        []
    }
    
    func deleteCredentials(id: String) {
        
    }
    
    func deleteAllCredentials() {
        
    }
    
    typealias CredentialsType = SwedbankCredentials
    
    
}
