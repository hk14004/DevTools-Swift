import Combine
import Foundation

extension Publisher {
    public func receiveOnMainThread() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        receive(on: DispatchQueue.main)
    }
}
