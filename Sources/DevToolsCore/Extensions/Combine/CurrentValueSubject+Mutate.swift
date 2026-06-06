//
//  CurrentValueSubject+Mutate.swift
//

import Combine

extension CurrentValueSubject {

    /// Applies an in-place mutation to the subject's current value and publishes
    /// the result in a single call.
    ///
    /// The three-step copy–mutate–send pattern is verbose and error-prone: if you
    /// forget to call `send()` the mutation is silently lost. `mutate` makes it
    /// impossible to forget.
    ///
    /// ```swift
    /// // Before
    /// var items = subject.value
    /// items.append(newItem)
    /// subject.send(items)
    ///
    /// // After
    /// subject.mutate { $0.append(newItem) }
    ///
    /// // Works for any value type mutation
    /// subject.mutate { $0.isLoading = true }
    /// subject.mutate { $0[id] = updatedModel }
    /// ```
    public func mutate(_ mutation: (inout Output) -> Void) {
        var current = value
        mutation(&current)
        send(current)
    }
}
