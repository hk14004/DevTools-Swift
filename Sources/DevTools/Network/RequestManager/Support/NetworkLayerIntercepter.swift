//
//  NetworkLayerIntercepter.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

public protocol NetworkLayerIntercepter: AnyObject {
    func requestCreated<T: TargetType>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void)
    func requestDidLaunch<T: TargetType>(requestID: String, target: T)
    func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T)
    func requestDidCancel<T: TargetType>(requestID: String, target: T)
}
