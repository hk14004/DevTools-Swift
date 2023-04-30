//
//  DataSynchronizer.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionDataSynchronizerProtocol: AnyObject {
    associatedtype T: AuthorizedEntityProtocol
    var syncingUserSession: Bool { get set }
    func syncUserSession(forEntity entity: T) async throws
}

public protocol GuestDataSynchronizer: AnyObject {
    var syncingGuestData: Bool { get set }
    func syncGuestData() async throws
}
