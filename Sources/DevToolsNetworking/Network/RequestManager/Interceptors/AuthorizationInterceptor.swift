//
//  AuthorizationInterceptor.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

open class AuthorizationInterceptor<T: TargetType> {

    typealias RequestID = String
    private let authorizationIssueStatusCode: Int = 401
    private let secondsLeftBeforeTriggerAuthTokenUpdate: Int = 3600 * 4
    private var refreshingToken = false
    private var waitingHandlersForNewToken: [RequestID : ()->()] = [:]
    
}

// MARK: Private

extension AuthorizationInterceptor {
    private func updateAccessToken<T: TargetType>(_ provider: MoyaProvider<T>, _ target: T, completion: @escaping () -> Void) {
        // 1. Fetch token
        // 2. Store where provider can access it
        fatalError("Implement")
    }
    
    private func notifyTokenUpdated() {
        waitingHandlersForNewToken.forEach { stored in
            stored.value()
        }
        waitingHandlersForNewToken = [:]
    }
    
    private func didAuthorizationFail(error: MoyaError) -> Bool {
        guard let responseCode = error.response?.statusCode else {
            return false
        }
        let authFailed = responseCode == authorizationIssueStatusCode
        return authFailed
    }
    
    private func getAuthorizationExpiryFromRequestInSeconds(result: Result<Response, MoyaError>) -> Int? {
        // Process response result and return token ETA
        fatalError("Implement")
    }
    
    private func isStoredTokenExpired() -> Bool {
        fatalError("Implement")
    }
}

// MARK: NetworkLayerInterceptor

extension AuthorizationInterceptor: NetworkLayerInterceptor {
    
    public func shouldRequestComplete<T>(requestID: String,
                                         provider: MoyaProvider<T>,
                                         result: Result<Moya.Response, Moya.MoyaError>,
                                         target: T,
                                         reLaunchClosure: @escaping ()->()) -> Bool where T : Moya.TargetType {
        switch result {
        case .success:
            return true
        case .failure(let failure):
            if didAuthorizationFail(error: failure) {
                waitingHandlersForNewToken[requestID] = reLaunchClosure
                if !refreshingToken {
                    refreshingToken = true
                    updateAccessToken(provider, target, completion: {
                        self.refreshingToken = false
                        self.notifyTokenUpdated()
                    })
                }
                return false
            } else {
                return true
            }
        }
    }
    
    public func requestCreated<T>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void) where T : Moya.TargetType {
        guard isStoredTokenExpired() else {
            startRequest()
            return
        }
        
        waitingHandlersForNewToken[requestID] = startRequest
        if !refreshingToken {
            refreshingToken = true
            updateAccessToken(provider, target, completion: {
                self.refreshingToken = false
                self.notifyTokenUpdated()
            })
        }
    }

    public func requestDidLaunch<T>(requestID: String, target: T) where T : Moya.TargetType {}
    public func requestDidCancel<T>(requestID: String, target: T) where T : Moya.TargetType {}
    public func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T) {}
}
