import Foundation

/// Mutable context a request is built in.
///
/// Holds a single `URLRequest` as the only source of truth — every other
/// property is a projection that reads and writes through it.
public final class RequestState {
    public var request: URLRequest
    public var encoder: JSONEncoder

    init(request: URLRequest = URLRequest(url: .placeholder), encoder: JSONEncoder = JSONEncoder()) {
        self.request = request
        self.encoder = encoder
    }
}

public extension RequestState {
    /// Backed by the relative-URL structure of `request.url`.
    ///
    /// Limitation: the base URL is meant to be applied after path and query.
    /// Setting `request.url` to an absolute URL directly discards the base.
    var baseURL: URL? {
        get { request.url?.baseURL }
        set { request.url = urlComponents.url(relativeTo: newValue) }
    }

    /// Backed by the relative part of `request.url`.
    var urlComponents: URLComponents {
        get { URLComponents(string: request.url?.relativeString ?? "") ?? URLComponents() }
        set { request.url = newValue.url(relativeTo: baseURL) }
    }

    /// Backed by `request.httpBody`, form-url-encoded.
    var encodedBodyItems: [URLQueryItem] {
        get {
            let body = request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? ""
            return URLComponents(string: "?" + body)?.queryItems ?? []
        }
        set {
            var components = URLComponents()
            components.queryItems = newValue
            request.httpBody = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B") // form parsers read "+" as space
                .data(using: .utf8)
        }
    }

    /// Backed by the `Cookie` header of `request`.
    var cookies: [String: String] {
        get {
            let header = request.value(forHTTPHeaderField: Header.cookie.rawValue) ?? ""
            let pairs = header.split(separator: ";").compactMap { component -> (String, String)? in
                let parts = component.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { return nil }
                return (
                    parts[0].trimmingCharacters(in: .whitespaces),
                    parts[1].trimmingCharacters(in: .whitespaces)
                )
            }
            return Dictionary(pairs) { _, last in last }
        }
        set {
            let header = newValue
                .map { "\($0.key)=\($0.value)" }
                .sorted()
                .joined(separator: "; ")
            request.setValue(header.isEmpty ? nil : header, forHTTPHeaderField: Header.cookie.rawValue)
        }
    }
}

public extension RequestState {
    var pathString: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }

    var queryItems: [URLQueryItem] {
        get { urlComponents.queryItems ?? [] }
        set { urlComponents.queryItems = newValue }
    }
}
