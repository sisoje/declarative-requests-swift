import Foundation

public struct RequestBuilderState {
    public init(
        baseURL: URL? = nil,
        pathComponents: URLComponents = .init(),
        request: URLRequest = .init(url: URL(fileURLWithPath: ""))
    ) {
        self.baseURL = baseURL
        self.pathComponents = pathComponents
        _request = request
    }

    public var baseURL: URL?
    public var pathComponents: URLComponents
    private var _request: URLRequest
    public var request: URLRequest {
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

public extension RequestBuilderState {
    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> some RequestBuilderNode {
        RootNode {
            $0[keyPath: keyPath] = value
        }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: @escaping () throws -> T) -> some RequestBuilderNode {
        RootNode {
            try $0[keyPath: keyPath] = value()
        }
    }
}
