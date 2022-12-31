//
//  RequestInfo.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Moya

extension MoyaRequestManager {
    struct RequestInfo {
        weak var provider: MoyaProvider<T>?
        var target: T
        var completionHandlers: [(Result<Response, MoyaError>) -> Void]
    }
}
