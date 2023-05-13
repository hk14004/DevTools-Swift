//
//  Tests.swift
//  
//
//  Created by Hardijs Ķirsis on 09/04/2023.
//

import XCTest
import DevToolsNetworking
import Moya

final class AuthorizationInterceptorTests: XCTestCase {

    func testSomething() throws {
        // Given
        
        let exp1 = XCTestExpectation(description: "Completion handler should be called")
        let manager = RequestManager<TestTarget>()
        let sut = makeSUT()
        sut.isStoredTokenExpiredResult = true
        let provider = MoyaProvider<TestTarget>(endpointClosure: { target in
                .init(url: URL(target: target).absoluteString,
                      sampleResponseClosure: {.networkResponse(401, target.sampleData)}, method: target.method, task: target.task,
                      httpHeaderFields: target.headers)
        },stubClosure: MoyaProvider.delayedStub(0.1))
        manager.delegates.append(sut)
        let target = TestTarget(endpoint: .someDataRequest)
        
        // When
        
        // Create test so that launching request fails because of auth issue
        // Create test so that initial requests lunch is postponed because local token is outDATED
        manager.launchSingleUniqueRequest(requestID: target.defaultUUID,
                                          target: target,
                                          provider: provider,
                                          hookRunning: true,
                                          retryMethod: .default) { result in
            exp1.fulfill()
        }
        
        // Then
        
        wait(for: [exp1], timeout: 3)
        assert(sut.updateAccessTokenCalled)
        
    }
    
    fileprivate func makeSUT() -> TestAuthInterceptor {
        return TestAuthInterceptor()
    }

}

fileprivate class TestAuthInterceptor: AuthorizationInterceptor<TestTarget> {
    
    var isStoredTokenExpiredResult = false
    var getAuthorizationExpiryFromRequestInSecondsResult = 100
    var updateAccessTokenCalled = false
    
    override func updateAccessToken<T>(_ provider: MoyaProvider<T>, _ target: T,
                                       completion: @escaping () -> Void) where T : TargetType {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateAccessTokenCalled = true
            completion()
        }
    }
    
    override func getAuthorizationExpiryFromRequestInSeconds(result: Result<Response, MoyaError>) -> Int? {
        // Process response result and return token ETA
        return getAuthorizationExpiryFromRequestInSecondsResult
    }
    
    override func isStoredTokenExpired() -> Bool {
        return isStoredTokenExpiredResult
    }
    
}
