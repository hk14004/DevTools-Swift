//
//  RequestManager.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation
import Moya

public final class MoyaRequestManager<T: TargetType> {

    private var requestsInProgress = [String: RequestInfo]()
    private var groupsInProgress = [String: GroupRequest<T>]()
    private var cancellables = [String: Cancellable]()
    
    public var delegates = [NetworkLayerIntercepter]()

    // MARK: Init
    
    public init() {}
}

// MARK: Public

extension MoyaRequestManager {
    
    public func isRequestInProgress(requestID: String) -> Bool {
        requestsInProgress.keys.contains(requestID)
    }
    
    public func isGroupRequestInProgress(groupID: String) -> Bool {
        groupsInProgress.keys.contains(groupID)
    }
    
    public func cancelRequest(requestID: String) {
        // Cancel the request if it exists
        guard let request = requestsInProgress.removeValue(forKey: requestID) else {
            return
        }
        cancellables.removeValue(forKey: requestID)?.cancel()
        request.completionHandlers.forEach({ $0(.failure(.underlying(MoyaRequestManagerError.canceledRequest, nil)))})
        delegates.forEach { delegate in
            delegate.requestDidCancel(requestID: requestID, target: request.target)
        }
    }
    
    public func cancelAllRequests() {
        for (requestID, _) in requestsInProgress {
            cancelRequest(requestID: requestID)
        }
    }

    public func cancelGroupRequest(groupID: String) {
        // Check if the group exists
        guard let group = groupsInProgress.removeValue(forKey: groupID) else {
            return
        }

        // Cancel all requests in the group
        for request in group.requests {
            cancelRequest(requestID: request.requestID)
        }
    }
    
    @discardableResult
    public func launchGroupRequest(groupRequest: GroupRequest<T>, provider: MoyaProvider<T>, behaviour: GroupRequestBehaviour, hookRunning: Bool, completion: @escaping ([String: Result<Response, MoyaError>]) -> Void) -> Bool {
        guard !groupsInProgress.keys.contains(groupRequest.id) else {
            return false
        }
        groupsInProgress[groupRequest.id] = groupRequest
        let workCompletionGroup = DispatchGroup()
        var results = [String: Result<Response, MoyaError>]()
        
        func launchRequests() {
            for request in groupRequest.requests {
                workCompletionGroup.enter()
                switch behaviour {
                case .parallel:
                   let launched = launchSingleUniqueRequest(requestID: request.requestID, provider: provider, target: request.targetType, hookRunning: hookRunning, retryMethod: request.retryMethod) { result in
                       results[request.requestID] = result
                       workCompletionGroup.leave()
                    }
                    if !launched {
                        workCompletionGroup.leave()
                    }
                case .oneAfterAnother:
                    let semaphore = DispatchSemaphore(value: 0)
                    let launched = launchSingleUniqueRequest(requestID: request.requestID, provider: provider, target: request.targetType, hookRunning: hookRunning, retryMethod: request.retryMethod) { result in
                        results[request.requestID] = result
                        semaphore.signal()
                        workCompletionGroup.enter()
                    }
                    if !launched {
                        workCompletionGroup.leave()
                    } else {
                        semaphore.wait()
                    }
                }
            }
        }
        
        let queue = DispatchQueue(label: "\(Self.Type.self) - Group UUID (\(groupRequest.id)")

        queue.async {
            launchRequests()
        }
        workCompletionGroup.notify(queue: .main) {
            completion(results)
        }
        
        return true
    }
    
    @discardableResult
    public func launchSingleUniqueRequest(requestID: String, provider: MoyaProvider<T>, target: T, hookRunning: Bool, retryMethod: RetryMethod, completion: @escaping (Result<Response, MoyaError>) -> Void) -> Bool {
        if var requestInfo = requestsInProgress[requestID] {
            // A request with the same ID is already in progress
            if hookRunning {
                requestInfo.completionHandlers.append(completion)
                requestsInProgress[requestID] = requestInfo
                return true
            } else {
                return false
            }
        } else {
            let group = DispatchGroup()
            for delegate in self.delegates {
                group.enter()
                delegate.requestCreated(requestID: requestID, provider: provider, target: target) {
                    group.leave()
                }
            }
            let newRequestInfo = RequestInfo(target: target, completionHandlers: [completion])
            requestsInProgress[requestID] = newRequestInfo
            group.notify(queue: .main) {
                for delegate in self.delegates {
                    delegate.requestDidLaunch(requestID: requestID, target: target)
                }
                self.request(requestID: requestID, provider: provider, target: target, retryMethod: retryMethod) { result in
                    self.requestsInProgress[requestID]?.completionHandlers.forEach({ closure in
                        closure(result)
                    })
                    self.requestCompleted(requestID: requestID, result: result, target: target)
                }
            }
            return true
        }
    }
}

// MARK: Private

extension MoyaRequestManager {
    private func requestCompleted(requestID: String, result: Result<Response, MoyaError>, target: T) {
        self.cancellables.removeValue(forKey: requestID)
        self.requestsInProgress.removeValue(forKey: requestID)
        for delegate in self.delegates {
            delegate.requestDidComplete(requestID: requestID, result: result, target: target)
        }
    }
    
    private func request(requestID: String, provider: MoyaProvider<T>, target: T, retryMethod: RetryMethod, completion: @escaping (Result<Response, MoyaError>) -> Void) {
        var retries = 0
        func retry(timesAlreadyRetried: Int, retryLimit: Int, interval: Double, exponentialBackOff: Bool) {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                guard let _self = self else { return }
                guard !_self.isRequestInProgress(requestID: requestID) else {
                    return
                }
                self?.cancellables[requestID] = provider.request(target) { result in
                    if case .failure(_) = result, timesAlreadyRetried < retryLimit {
                        retries += 1
                        let newInterval: Double = exponentialBackOff ? interval * pow(2.0, Double(timesAlreadyRetried)) : interval
                        retry(timesAlreadyRetried: retries, retryLimit: retryLimit, interval: newInterval, exponentialBackOff: exponentialBackOff)
                    } else {
                        completion(result)
                    }
                }
            }
        }
        
        cancellables[requestID] = provider.request(target) { result in
            switch retryMethod {
            case .retry(let maxRetryCount, let seconds, let exponentialBackOff):
                if case .failure(_) = result, maxRetryCount > 0 {
                    retry(timesAlreadyRetried: 0, retryLimit: maxRetryCount, interval: Double(seconds), exponentialBackOff: exponentialBackOff)
                } else {
                    completion(result)
                }
            case .default:
                completion(result)
            }
        }
    }
}
