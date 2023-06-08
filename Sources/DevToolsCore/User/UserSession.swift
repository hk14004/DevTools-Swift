//
//  AuthorizedUserSession.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSession: UserSessionDataSynchronizer {
    associatedtype T: AuthorizationCredentials
    var credentils: T { get set }
}

public protocol AuthorizationCredentials {
    associatedtype T // May hold token and other related data
    var id: String { get }
    var authorizationData: T { get }
}
