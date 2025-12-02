import Foundation

public final class RequestState {
    public init() {}
    public var request = URLRequest(url: URLComponents().url!)
    public var encoder = JSONEncoder()
    public var cookies: [String: String] = [:]

    var urlComponents: URLComponents {
        URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
    }

    func setBaseURL(_ url: URL) {
        request.url = urlComponents.url(relativeTo: url)!
    }

    func setPath(_ path: String) {
        var urlComponents = urlComponents
        urlComponents.path = path
        request.url = urlComponents.url!
    }

    var queryItems: [URLQueryItem] {
        get {
            urlComponents.queryItems ?? []
        }
        set {
            var urlComponents = urlComponents
            urlComponents.queryItems = newValue
            request.url = urlComponents.url!
        }
    }

    var encodedBodyItems: [URLQueryItem] {
        get {
            request.httpBody.flatMap { bodyData in
                var comp = URLComponents()
                comp.percentEncodedQuery = String(decoding: bodyData, as: UTF8.self)
                return comp.queryItems
            } ?? []
        }
        set {
            var comp = URLComponents()
            comp.queryItems = newValue
            request.httpBody = comp.percentEncodedQuery?.data(using: .utf8)
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
