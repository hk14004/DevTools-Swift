//
//  RequestManagerTarget.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import Moya

public protocol RequestManagerTarget: TargetType {
    
    associatedtype API_Endpoint: RawRepresentable, CaseIterable
    var defaultUUID: String { get }
    var endpoint: API_Endpoint { get }
    var resourceIDs: [String]? { get }
    var urlParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    var headerParameter: [String: String]? { get }
    
}

struct ExampleRequestManagerTarget: RequestManagerTarget {
    
    // MARK: Types
    
    enum Endpoint: String, CaseIterable {
        case getData
    }
    
    // MARK: Properties
    
    // Input
    var endpoint: Endpoint

    var urlParameters: [String : Any]?
    
    var bodyParameters: [String : Any]?
    
    var resourceIDs: [String]?
    
    var headerParameter: [String : String]?
    
    // Computed
    var defaultUUID: String {
        endpoint.rawValue
    }
    
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var path: String {
        switch endpoint {
        case .getData:
            return "/myData"
        }
    }
    
    var method: Moya.Method {
        switch endpoint {
        case .getData:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch endpoint {
        default:
            return .requestCompositeParameters(bodyParameters: bodyParameters ?? [:],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: urlParameters ?? [:])
        }
    }
    
    var headers: [String : String]?
    
}
