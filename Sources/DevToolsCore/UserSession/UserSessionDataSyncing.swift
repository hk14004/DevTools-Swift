//
//  DataSynchronizer.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public protocol UserSessionDataSyncing: AnyObject {
    var syncingUserSession: Bool { get set }
    func syncUserSession() async throws
    func cancelSync()
}

public protocol GuestDataSyncing: AnyObject {
    var syncingGuestData: Bool { get set }
    func syncGuestData() async throws
    func cancelSync()
}
