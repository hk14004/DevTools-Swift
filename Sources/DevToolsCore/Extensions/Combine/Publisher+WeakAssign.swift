//
//  Publisher+WeakAssign.swift
//

import Combine

extension Publisher where Failure == Never {

    /// Assigns each output value to a property on `object`, holding only a **weak**
    /// reference to it.
    ///
    /// The standard `assign(to:on:)` strongly retains the object, which creates a
    /// retain cycle when the object also holds the cancellable (the common ViewModel
    /// pattern). `weakAssign` breaks that cycle.
    ///
    /// ```swift
    /// // ViewModel
    /// viewModel.$title
    ///     .weakAssign(to: \.titleLabel.text, on: self)
    ///     .store(in: &cancellables)
    /// ```
    public func weakAssign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on object: Root
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
