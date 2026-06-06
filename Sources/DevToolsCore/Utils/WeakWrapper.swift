//
//  WeakWrapper.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

/// Holds a weak reference to a class instance.
///
/// Useful for storing delegates, observers, or any object you want to reference
/// without creating a retain cycle — particularly in arrays of callbacks or
/// multi-delegate patterns.
///
/// ```swift
/// var observers: [WeakWrapper<MyObserver>] = []
/// observers.append(WeakWrapper(self))
///
/// // Compact out deallocated observers
/// observers = observers.filter { $0.value != nil }
/// observers.forEach { $0.value?.notify() }
/// ```
public class WeakWrapper<T: AnyObject> {
    public weak var value: T?

    public init(_ value: T) {
        self.value = value
    }
}
