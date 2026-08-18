import Foundation

/// Mutable context a request is built in.
///
/// Holds a single `URLRequest` as the only source of truth — every other
/// property is a projection that reads and writes through it.
///
/// Confined by construction, which is what the unchecked conformance
/// asserts: an instance is created inside `request(initialRequest:)`,
/// mutated synchronously by that one call's block transforms, and dropped
/// when the `URLRequest` is returned. It is never handed across an
/// isolation boundary, so there is no concurrent access to guard.
public final class RequestState: @unchecked Sendable {
    public var request: URLRequest
    public var encoder: JSONEncoder

    init(request: URLRequest? = nil, encoder: JSONEncoder? = nil) {
        self.request = request ?? URLRequest(url: .placeholder)
        self.encoder = encoder ?? JSONEncoder()
    }
}

public extension RequestState {
    /// Combines the base into `request.url`: accumulated path and query are
    /// appended onto it. Apply after path and query; there is no readback —
    /// combination consumes the base/path boundary.
    func setBaseURL(_ url: URL) {
        var url = url
        let urlComponents = urlComponents
        if !urlComponents.path.isEmpty {
            url.append(path: urlComponents.path)
        }
        if let queryItems = urlComponents.queryItems, !queryItems.isEmpty {
            url.append(queryItems: queryItems)
        }
        request.url = url
    }

    /// Backed by `request.url`, resolved.
    private var urlComponents: URLComponents {
        get { URLComponents(url: request.url ?? .placeholder, resolvingAgainstBaseURL: false) ?? URLComponents() }
        set { request.url = newValue.url }
    }

    /// Backed by `request.httpBody`, form-url-encoded.
    internal var encodedBodyItems: [URLQueryItem] {
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
    var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }

    var queryItems: [URLQueryItem] {
        get { urlComponents.queryItems ?? [] }
        set { urlComponents.queryItems = newValue }
    }
}
