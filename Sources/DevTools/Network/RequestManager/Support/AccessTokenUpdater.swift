//
//  AccessTokenUpdater.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

extension RequestManager {
    class AccessTokenUpdater: NetworkLayerIntercepter {
        func requestDidCancel<T>(requestID: String, target: T) where T : Moya.TargetType {
            // No action required
        }
        
        func requestCreated<T>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void) where T : Moya.TargetType {
            updateAccessToken(provider, target) {
                startRequest()
            }
        }
        
        func requestDidLaunch<T: TargetType>(requestID: String, target: T) {
            // No action required
        }
        
        func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T) {
            // No action required
        }
        
        private func updateAccessToken<T: TargetType>(_ provider: MoyaProvider<T>, _ target: T, completion: @escaping () -> Void) {
            // Update the access token for the given target
            // Once the access token has been updated, call the completion closure
            completion()
        }
    }
}
