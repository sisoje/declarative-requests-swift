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
    /// Combines the base into `request.url`: accumulated path and query are
    /// appended onto it. Apply after path and query; there is no readback —
    /// combination consumes the base/path boundary.
    func setBaseURL(_ url: URL) {
        var url = url
        let combinedComponents = urlComponents
        if !combinedComponents.path.isEmpty {
            url.append(path: combinedComponents.path)
        }
        if let queryItems = combinedComponents.queryItems {
            url.append(queryItems: queryItems)
        }
        request.url = url
    }

    /// Backed by `request.url`, resolved.
    private var urlComponents: URLComponents {
        get { URLComponents(url: request.url ?? .placeholder, resolvingAgainstBaseURL: true) ?? URLComponents() }
        set { request.url = newValue.url }
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
