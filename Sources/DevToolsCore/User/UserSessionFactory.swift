//
//  UserSessionFactory.swift
//  
//
//  Created by Hardijs Ķirsis on 08/06/2023.
//

import Foundation

protocol UserSessionFactory {
    associatedtype UserSessionType: UserSession
    func makeUserSession(with credentials: UserSessionType.CredentialsType) -> UserSessionType
}
