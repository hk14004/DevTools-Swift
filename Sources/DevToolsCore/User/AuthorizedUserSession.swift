//
//  AuthorizedUserSession.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol AuthorizedUserSession: UserSessionDataSynchronizer where T: AuthorizedEntity {
    
    var authorizedEntity: T { get set }
    
}
