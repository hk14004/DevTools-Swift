//
//  DataSynchronizer.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionDataSynchronizer: AnyObject {
    var syncingUserSession: Bool { get set }
    func syncUserSession() async throws
    func cancelSync()
}

public protocol GuestDataSynchronizer: AnyObject {
    var syncingGuestData: Bool { get set }
    func syncGuestData() async throws
}
