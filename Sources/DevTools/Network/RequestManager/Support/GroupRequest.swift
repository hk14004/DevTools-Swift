//
//  GroupRequest.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import Moya

extension MoyaRequestManager {
    public struct GroupRequest<T: TargetType> {
            let id: String
            let requests: [RequestMetaData]
        
        struct RequestMetaData {
            let targetType: T
            let requestID: String
            let retryMethod: RetryMethod
        }
    }

    public enum GroupRequestBehaviour {
        case parallel
        case oneAfterAnother
    }
}
