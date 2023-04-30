//
//  DataSynchronizer.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionDataSynchronizer: AnyObject {
    associatedtype T: AuthorizedEntity
    var syncingUserSession: Bool { get set }
    func syncUserSession(forEntity entity: T, completion: @escaping(_ success: Bool)->())
}

public protocol GuestDataSynchronizer: AnyObject {
    var syncingGuestData: Bool { get set }
    func syncGuestData(completion: @escaping(_ success: Bool)->())
}
