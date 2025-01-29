import Foundation

public struct RequestBuilderState {
    var baseURL: URL?
    var pathComponents: URLComponents = .init()
    private var _request: URLRequest = .init(url: URL(fileURLWithPath: ""))
    var request: URLRequest {
        get {
            var res = _request
            res.url = pathComponents.url(relativeTo: baseURL)
            return res
        }
        set {
            _request = newValue
        }
    }
}

extension RequestBuilderState {
    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> CustomTransformer {
        CustomTransformer {
            $0[keyPath: keyPath] = value
        }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: @escaping () throws -> T) -> CustomTransformer {
        CustomTransformer {
            try $0[keyPath: keyPath] = value()
        }
    }
}
