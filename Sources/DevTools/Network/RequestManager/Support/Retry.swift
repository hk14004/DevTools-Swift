//
//  Retry.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

extension RequestManager {
    public enum RetryMethod {
        case `default`
        case retry(maxRetryCount: Int, seconds: Int, exponentialBackOff: Bool)
    }
}
