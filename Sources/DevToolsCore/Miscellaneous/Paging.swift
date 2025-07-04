//
//  Paging.swift
//  
//
//  Created by Hardijs Ķirsis on 08/04/2023.
//

import Foundation

public struct DevPagedResult<T> {
    public let pageNumber: Int
    public let pageItems: [T]
    public let hasNextPage: Bool
    
    public init(pageNumber: Int, pageItems: [T], hasNextPage: Bool) {
        self.pageNumber = pageNumber
        self.pageItems = pageItems
        self.hasNextPage = hasNextPage
    }
}

extension DevPagedResult: Hashable {
    public static func == (lhs: DevPagedResult<T>, rhs: DevPagedResult<T>) -> Bool {
        return lhs.pageNumber == rhs.pageNumber
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pageNumber)
    }
}

public struct DevPagedRequestOptions {
    public let fetchPage: Int
    public let pageSize: Int
    
    public init(fetchPage: Int, pageSize: Int) {
        self.fetchPage = fetchPage
        self.pageSize = pageSize
    }
}
