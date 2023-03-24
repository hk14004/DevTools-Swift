//
//  NetworkLayerInterceptor.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

public protocol NetworkLayerInterceptor: AnyObject {
    func requestCreated<T: TargetType>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void)
    func requestDidLaunch<T: TargetType>(requestID: String, target: T)
    func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T)
    func requestDidCancel<T: TargetType>(requestID: String, target: T)
}

extension NetworkLayerInterceptor {
    public func requestCreated<T>(requestID: String, provider: Moya.MoyaProvider<T>, target: T, startRequest: @escaping () -> Void) where T : Moya.TargetType {
        // Allow request to fire
        startRequest()
    }
    
    public func requestDidLaunch<T>(requestID: String, target: T) where T : Moya.TargetType {
        // Do nothing
    }
    
    public func requestDidComplete<T>(requestID: String, result: Result<Moya.Response, Moya.MoyaError>, target: T) where T : Moya.TargetType {
        // Do nothing
    }
    
    public func requestDidCancel<T>(requestID: String, target: T) where T : Moya.TargetType {
        // Do nothing
    }
}
