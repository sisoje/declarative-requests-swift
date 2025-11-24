import Foundation

public struct RequestState {
    public init(
        baseURL: URL? = nil,
        pathComponents: URLComponents = .init(),
        encodedBodyItems: [URLQueryItem] = [],
        cookies: [String: String] = [:],
        request: URLRequest = .init(url: URL(fileURLWithPath: ""))
    ) {
        self.baseURL = baseURL
        self.pathComponents = pathComponents
        self.encodedBodyItems = encodedBodyItems
        self.cookies = cookies
        _request = request
    }

    public var encoder: JSONEncoder = .init()
    public var baseURL: URL?
    public var cookies: [String: String]
    public var encodedBodyItems: [URLQueryItem]
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
    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> RequestTransformation {
        RequestTransformation {
            $0[keyPath: keyPath] = value
        }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: @escaping () throws -> T) -> RequestTransformation {
        RequestTransformation {
            try $0[keyPath: keyPath] = value()
        }
    }
}
