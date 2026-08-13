import Foundation

public enum RequestMutation {
    public static subscript<T>(_ keyPath: WritableKeyPath<URLRequest, T>, _ value: @autoclosure @escaping () throws -> T) -> RequestBlock {
        RequestBlock { state in
            state.request[keyPath: keyPath] = try value()
        }
    }
}
