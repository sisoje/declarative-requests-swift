import Foundation

public struct RequestState {
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

public extension RequestState {
    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> RootNode {
        RootNode {
            $0[keyPath: keyPath] = value
        }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: @escaping () throws -> T) -> RootNode {
        RootNode {
            try $0[keyPath: keyPath] = value()
        }
    }
}
