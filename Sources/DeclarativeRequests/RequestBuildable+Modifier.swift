import Foundation

public extension RequestBuildable {
    func environment<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: T) -> RequestStateTransformer {
        RequestStateTransformer { state in
            let original = state[keyPath: keyPath]
            state[keyPath: keyPath] = value
            defer { state[keyPath: keyPath] = original }
            try transform(state)
        }
    }

    func headersAdd() -> RequestStateTransformer {
        environment(\.shouldAddHeaders, true)
    }

    func headersSet() -> RequestStateTransformer {
        environment(\.shouldAddHeaders, false)
    }
}
