import Foundation

public struct RequestMutation<Value>: RequestBuildable {
    public init(_ keyPath: WritableKeyPath<URLRequest, Value> & Sendable, _ value: @autoclosure @escaping @Sendable () throws -> Value) {
        self.keyPath = keyPath
        self.value = value
    }

    let keyPath: WritableKeyPath<URLRequest, Value> & Sendable
    let value: @Sendable () throws -> Value

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request[keyPath: keyPath] = try value()
        }
    }
}
