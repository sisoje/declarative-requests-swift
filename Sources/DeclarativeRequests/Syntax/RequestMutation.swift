import Foundation

public struct RequestMutation<Value>: RequestBuildable {
    public init(_ keyPath: WritableKeyPath<URLRequest, Value>, _ value: @autoclosure @escaping () throws -> Value) {
        self.keyPath = keyPath
        self.value = value
    }

    let keyPath: WritableKeyPath<URLRequest, Value>
    let value: () throws -> Value

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request[keyPath: keyPath] = try value()
        }
    }
}
