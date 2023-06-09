//
//  AuthorizedUserSession.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSession {
    associatedtype CredentialsType: AuthorizationCredentials
    var credentials: CredentialsType { get set }
}

public protocol AuthorizationCredentials {
    associatedtype AuthData // May hold token and other related data
    var id: String { get }
    var authorizationData: AuthData { get }
}

class SwedbankUserSession: UserSession {
    var credentials: SwedbankCredentials
    
    init(credentials: SwedbankCredentials) {
        self.credentials = credentials
    }
}

struct SwedbankCredentials: AuthorizationCredentials {
    struct Data {
        let token: String
    }
    var id: String
    var authorizationData: Data
}
