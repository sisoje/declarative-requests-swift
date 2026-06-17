import Foundation
import SwiftUI

@Observable public final class RequestState: @unchecked Sendable {
    internal init(
        baseURL: URL = .placeholder,
        urlComponents: URLComponents = URLComponents(),
        request: URLRequest = URLRequest(url: .placeholder),
        encoder: JSONEncoder = JSONEncoder(),
        shouldAddHeaders: Bool = true
    ) {
        self.baseURL = baseURL
        self.urlComponents = urlComponents
        self._request = request
        self.encoder = encoder
        self.shouldAddHeaders = shouldAddHeaders
    }
    
    public var baseURL: URL = .placeholder
    public var urlComponents: URLComponents = URLComponents()

    private var _request: URLRequest = URLRequest(url: .placeholder)
    public var request: URLRequest {
        get {
            var res = _request
            res.url = urlComponents.url(relativeTo: baseURL)
            return res
        }
        set {
            var res = newValue
            res.url = .placeholder
            _request = res
        }
    }

    public var encoder: JSONEncoder = JSONEncoder()

    public var shouldAddHeaders = true

    public var cookies: [String: String] {
        get {
            _request.value(forHTTPHeaderField: Header.cookie.rawValue)?
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
            _request.setValue(value, forHTTPHeaderField: Header.cookie.rawValue)
        }
    }

    var pathString: String {
        get {
            urlComponents.path
        }
        set {
            urlComponents.path = newValue
        }
    }

    var queryItems: [URLQueryItem] {
        get {
            urlComponents.queryItems ?? []
        }
        set {
            urlComponents.queryItems = newValue
        }
    }

    var encodedBodyItems: [URLQueryItem] {
        get {
            _request.httpBody.flatMap { bodyData in
                var comp = URLComponents()
                comp.percentEncodedQuery = String(decoding: bodyData, as: UTF8.self)
                return comp.queryItems
            } ?? []
        }
        set {
            var comp = URLComponents()
            comp.queryItems = newValue
            _request.httpBody = comp.percentEncodedQuery?.data(using: .utf8)
        }
    }

    func header(_ name: String) -> HeaderCap {
        HeaderCap(
            value: Binding(
                get: { self._request.value(forHTTPHeaderField: name) },
                set: { self._request.setValue($0, forHTTPHeaderField: name) }
            ),
            addValue: { self._request.addValue($0, forHTTPHeaderField: name) }
        )
    }
}
