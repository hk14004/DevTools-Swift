////
////  NetworkLayerInterceptor.swift
////  
////
////  Created by Hardijs on 31/12/2022.
////
//
//import Moya
//
//public enum InterceptorRequestWillCompleteDecision {
//    
//    public typealias Trigger = ()->()
//    case runRequestAgain(Trigger)
//    case allowToComplete
//    
//}
//
//
//public protocol NetworkLayerInterceptor: AnyObject {
//    func requestCreated<T: TargetType>(requestID: String, provider: MoyaProvider<T>, target: T, startRequest: @escaping () -> Void)
//    func requestDidLaunch<T: TargetType>(requestID: String, target: T)
//    func shouldRequestComplete<T: TargetType>(requestID: String, provider: MoyaProvider<T>, result: Result<Response, MoyaError>, target: T, reLaunchClosure: @escaping ()->()) -> Bool
//    func requestDidComplete<T: TargetType>(requestID: String, result: Result<Response, MoyaError>, target: T)
//    func requestDidCancel<T: TargetType>(requestID: String, target: T)
//}
