import Foundation

public extension RequestBuildable {
    /// Scopes a ``RequestState`` value to the receiver, restoring the prior value afterwards.
    ///
    /// Acts like SwiftUI's `View.environment(_:_:)`: blocks declared inside the receiver see
    /// `value` at `keyPath`; blocks declared after the modifier see the original value again.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into ``RequestState``.
    ///   - value: The value to apply for the duration of the inner build.
    func environment<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: T) -> RequestBlock {
        RequestBlock { state in
            let original = state[keyPath: keyPath]
            state[keyPath: keyPath] = value
            defer { state[keyPath: keyPath] = original }
            try transform(state)
        }
    }

    /// Pins ``RequestState/shouldAddHeaders`` to `true` for the receiver's scope.
    func headersAdd() -> RequestBlock {
        environment(\.shouldAddHeaders, true)
    }

    /// Pins ``RequestState/shouldAddHeaders`` to `false` for the receiver's scope.
    func headersSet() -> RequestBlock {
        environment(\.shouldAddHeaders, false)
    }
}
