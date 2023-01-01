//
//  AuthorizationInterceptor.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

class AuthorizationInterceptor<T: TargetType> {

    private let authorizationIssueStatusCode: Int = 401
    private let secondsLeftBeforeTriggerAuthorizationUpdate: Int = 3600 * 4
    
}

// MARK: Private

extension AuthorizationInterceptor {
    private func updateAccessToken<T: TargetType>(_ provider: MoyaProvider<T>, _ target: T, completion: @escaping () -> Void) {
        // Update the access token for the given target
        // Once the access token has been updated, call the completion closure
        completion()
    }
    
    private func didAuthorizationFail(error: MoyaError) -> Bool {
        guard let responseCode = error.response?.statusCode else {
            return false
        }
        let authFailed = responseCode == authorizationIssueStatusCode
        return authFailed
    }
    
    private func getAuthorizationExpiryInSeconds(result: Result<Response, MoyaError>) -> Int? {
        // TODO: Implement
        switch result {
        case .success(let response):
            return nil
        case .failure(let failure):
            return nil
        }
    }
    
}

// MARK: NetworkLayerInterceptor

extension AuthorizationInterceptor: NetworkLayerInterceptor {
    func requestCreated<T>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void) where T : Moya.TargetType {
        // Check access token?
        updateAccessToken(provider, target) {
            startRequest()
        }
    }

    // TODO: Add request will call completion handler
    // TODO: Change requestDidComplete to request received data
    func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T) {
        switch result {
        case .success:
            return
        case .failure(let failure):
            if didAuthorizationFail(error: failure) {
                // TODO: Retry request after auth attempt
            }
        }
    }
}
