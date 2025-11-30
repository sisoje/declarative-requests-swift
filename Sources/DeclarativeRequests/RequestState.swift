import Foundation

public final class RequestState {
    public init() {}
    public var encoder = JSONEncoder()
    public var baseURL: URL?
    public var cookies: [String: String] = [:]
    public var encodedBodyItems: [URLQueryItem] = []
    public var pathComponents = URLComponents()

    private var _request = URLRequest(url: URL(fileURLWithPath: ""))
    private func updateUrl() {
        _request.url = pathComponents.url(relativeTo: baseURL)
    }

    public var request: URLRequest {
        get {
            updateUrl()
            return _request
        }
        set {
            _request = newValue
            updateUrl()
        }
    }
}

public extension RequestState {
    static subscript<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: @autoclosure @escaping () throws -> T) -> RequestTransformation {
        RequestTransformation { state in
            state[keyPath: keyPath] = try value()
        }
    }
}
