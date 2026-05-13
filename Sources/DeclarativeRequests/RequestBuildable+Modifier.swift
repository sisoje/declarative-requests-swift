import Foundation

public extension RequestBuildable {
    func environment<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: T) -> RequestBlock {
        RequestBlock { state in
            let original = state[keyPath: keyPath]
            state[keyPath: keyPath] = value
            defer { state[keyPath: keyPath] = original }
            try transform(state)
        }
    }

    func headersAdd() -> RequestBlock {
        environment(\.shouldAddHeaders, true)
    }

    func headersSet() -> RequestBlock {
        environment(\.shouldAddHeaders, false)
    }
}
