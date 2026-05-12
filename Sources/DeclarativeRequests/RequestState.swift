import Foundation

public final class RequestState {
    init(
        request: URLRequest = URLRequest(url: .placeholder),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.request = request
        self.encoder = encoder
    }

    public var request: URLRequest

    public var encoder: JSONEncoder
    
    public var shouldAddHeaders = true

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

    private var urlComponents: URLComponents {
        request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) } ?? URLComponents()
    }

    var baseURL: URL {
        get {
            urlComponents.url ?? .placeholder
        }
        set {
            request.url = urlComponents.url(relativeTo: newValue)
        }
    }

    var pathArray: [String] {
        get {
            pathString.components(separatedBy: "/")
        }
        set {
            pathString = newValue.joined(separator: "/")
        }
    }

    var pathString: String {
        get {
            urlComponents.path
        }
        set {
            var urlComponents = urlComponents
            urlComponents.path = newValue
            request.url = urlComponents.url
        }
    }

    var queryItems: [URLQueryItem] {
        get {
            urlComponents.queryItems ?? []
        }
        set {
            var urlComponents = urlComponents
            urlComponents.queryItems = newValue
            request.url = urlComponents.url
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
