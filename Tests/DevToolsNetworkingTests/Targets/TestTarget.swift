//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import Foundation
import DevToolsNetworking
import Moya

struct TestTarget: RequestManagerTarget {
    
    // MARK: Types
    
    enum Endpoint: String, CaseIterable {
        case someDataRequest
        case refreshToken
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
        return URL(string: "www.google.com")!
    }
    
    var path: String {
        switch endpoint {
        case .someDataRequest:
            return "/myData"
        case .refreshToken:
            return "/refreshToken"
        }
    }
    
    var method: Moya.Method {
        switch endpoint {
        case .someDataRequest:
            return .get
        case .refreshToken:
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
    
    var sampleData: Data {
        switch self.endpoint {
        case .someDataRequest:
            return "{'message': 'Not Found'}".data(using: .utf8)!
            
        case .refreshToken:
            return "{'token': '1234567890'}".data(using: .utf8)!
        }
    }

}
