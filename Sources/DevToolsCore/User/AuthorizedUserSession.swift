//
//  AuthorizedUserSession.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol AuthorizedUserSessionProtocol: UserSessionDataSynchronizerProtocol where T: AuthorizedEntityProtocol {
    
    var authorizedEntity: T { get set }
    
}
