import Foundation

public final class RequestState {
    public init(
        request: URLRequest = URLRequest(url: URLComponents().url!),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.request = request
        self.encoder = encoder
    }

    public var request: URLRequest
    public let encoder: JSONEncoder

    public var cookies: [String: String] {
        get {
            request.value(forHTTPHeaderField: Header.cookie.rawValue)?
                .split(separator: ";")
                .reduce(into: [:]) { result, component in
                    let parts = component.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        let key = parts[0].trimmingCharacters(in: .whitespaces)
                        let value = parts[1].trimmingCharacters(in: .whitespaces)
                        result[key] = value
                    }
                } ?? [:]
        }
        set {
            let cookieString = newValue
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "; ")
            let value = cookieString.isEmpty ? nil : cookieString
            request.setValue(value, forHTTPHeaderField: Header.cookie.rawValue)
        }
    }

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
    static subscript<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: @autoclosure @escaping () throws -> T) -> RequestBlock {
        RequestBlock { state in
            state[keyPath: keyPath] = try value()
        }
    }
}
