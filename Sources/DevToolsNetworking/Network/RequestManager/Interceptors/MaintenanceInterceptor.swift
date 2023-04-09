//
//  MaintenanceInterceptor.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import Moya

public class MaintenanceInterceptor<T: TargetType> {
    
    private let maintenanceStatusCode: Int
    private var lastRequestWasUnderMaintenance: Bool = false
    
    init(maintenanceStatusCode: Int) {
        self.maintenanceStatusCode = maintenanceStatusCode
    }
}

// MARK: Private

extension MaintenanceInterceptor {
    private func notifyMaintenanceChanged(enabled: Bool) {
        // TODO: Implement your maintenance trigger
    }
    
    private func getStatusCode(moyaResponse: Result<Moya.Response, Moya.MoyaError>) -> Int? {
        switch moyaResponse {
        case .success(let success):
            return success.statusCode
        case .failure(let failure):
            return failure.response?.statusCode
        }
    }
    
}

// MARK: NetworkLayerInterceptor

extension MaintenanceInterceptor: NetworkLayerInterceptor {
    
    public func requestDidComplete<T>(requestID: String, result: Result<Moya.Response, Moya.MoyaError>, target: T) where T : Moya.TargetType {
        guard let code = getStatusCode(moyaResponse: result) else {
            // No response
            return
        }
        let didReceiveMaintenanceMode = code == maintenanceStatusCode
        
        if lastRequestWasUnderMaintenance != didReceiveMaintenanceMode {
            notifyMaintenanceChanged(enabled: didReceiveMaintenanceMode)
        }
        lastRequestWasUnderMaintenance = didReceiveMaintenanceMode
    }
    
    public func requestCreated<T>(requestID: String, provider: Moya.MoyaProvider<T>, target: T, startRequest: @escaping () -> Void) where T : Moya.TargetType {
        startRequest()
    }
    
    public func requestDidLaunch<T>(requestID: String, target: T) where T : Moya.TargetType {}
    
    public func shouldRequestComplete<T>(requestID: String, provider: Moya.MoyaProvider<T>, result: Result<Moya.Response, Moya.MoyaError>, target: T, reLaunchClosure: @escaping () -> ()) -> Bool where T : Moya.TargetType {
        return true
    }
    
    public func requestDidCancel<T>(requestID: String, target: T) where T : Moya.TargetType {}
    
}
