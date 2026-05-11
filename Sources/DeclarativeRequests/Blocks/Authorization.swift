import Foundation

/// Sets the `Authorization` header.
///
/// Pick the factory that matches your authentication scheme. Each one
/// formats the header value for you:
///
/// ```swift
/// // OAuth 2.0 bearer token (RFC 6750):
/// Authorization.bearer(accessToken)
/// // → Authorization: Bearer <token>
///
/// // HTTP Basic (RFC 7617) — encodes username:password to Base64 for you:
/// Authorization.basic(username: "alice", password: "s3cret")
/// // → Authorization: Basic YWxpY2U6czNjcmV0
///
/// // Token auth (e.g. Django REST Framework):
/// Authorization.token(apiKey)
/// // → Authorization: Token <key>
///
/// // Arbitrary "<Scheme> <credentials>" pair:
/// Authorization.other("HOBA", credentials: "...")
/// // → Authorization: HOBA ...
///
/// // Verbatim value — no scheme prefix:
/// Authorization.raw("my-opaque-key-12345")
/// // → Authorization: my-opaque-key-12345
///
/// // Custom authenticator — receives the request built so far:
/// Authorization.custom { request in
///     let signature = hmac(request.allHTTPHeaderFields, secret: key)
///     request.setValue("HMAC \(signature)", forHTTPHeaderField: "Authorization")
/// }
/// ```
public enum Authorization {}

public extension Authorization {
    /// Sets `Authorization: Bearer <token>` (RFC 6750).
    ///
    /// The token string is written verbatim after `Bearer `.
    ///
    /// ```swift
    /// Authorization.bearer(accessToken)
    /// // → Authorization: Bearer eyJhbGci...
    /// ```
    ///
    /// - Parameter token: The bearer token.
    static func bearer(_ token: String) -> some RequestBuildable {
        Header.authorization.setValue("Bearer \(token)")
    }

    /// Sets `Authorization: Basic <base64>` (RFC 7617).
    ///
    /// The username and password are joined with a colon, UTF-8 encoded, and
    /// Base64-encoded automatically.
    ///
    /// ```swift
    /// Authorization.basic(username: "alice", password: "s3cret")
    /// // → Authorization: Basic YWxpY2U6czNjcmV0
    /// ```
    ///
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    static func basic(username: String, password: String) -> some RequestBuildable {
        let base64 = Data("\(username):\(password)".utf8).base64EncodedString()
        return Header.authorization.setValue("Basic \(base64)")
    }

    /// Sets `Authorization: Token <token>`.
    ///
    /// Used by frameworks like Django REST Framework and some CI systems.
    ///
    /// ```swift
    /// Authorization.token(apiKey)
    /// // → Authorization: Token abc123
    /// ```
    ///
    /// - Parameter token: The token string.
    static func token(_ token: String) -> some RequestBuildable {
        Header.authorization.setValue("Token \(token)")
    }

    /// Sets `Authorization: <scheme> <credentials>` for a scheme not covered
    /// by the other factories.
    ///
    /// ```swift
    /// Authorization.other("HOBA", credentials: "...")
    /// // → Authorization: HOBA ...
    ///
    /// Authorization.other("Negotiate", credentials: negotiateToken)
    /// // → Authorization: Negotiate <token>
    /// ```
    ///
    /// - Parameters:
    ///   - scheme: The scheme name (e.g. `"HOBA"`, `"Negotiate"`, `"Digest"`).
    ///   - credentials: The credentials string written after the scheme name.
    static func other(_ scheme: String, credentials: String) -> some RequestBuildable {
        Header.authorization.setValue("\(scheme) \(credentials)")
    }

    /// Sets the `Authorization` header to a verbatim string with no scheme
    /// prefix.
    ///
    /// Use this for APIs that expect an opaque key or token without a named
    /// scheme:
    ///
    /// ```swift
    /// Authorization.raw("my-opaque-api-key-12345")
    /// // → Authorization: my-opaque-api-key-12345
    /// ```
    ///
    /// - Parameter value: The exact header value.
    static func raw(_ value: String) -> some RequestBuildable {
        Header.authorization.setValue(value)
    }

    /// Sets the `Authorization` header via a custom authenticator closure.
    ///
    /// The closure receives the in-progress `URLRequest` as an `inout`
    /// parameter after all preceding blocks have been applied. Use this for
    /// authentication schemes that derive credentials from the request itself
    /// — for example, HMAC signatures computed over headers or the body.
    ///
    /// Place this block **after** all headers, query items, and body blocks
    /// so the request is fully formed when the closure runs.
    ///
    /// ```swift
    /// let request = try URLRequest {
    ///     Method.POST
    ///     BaseURL("https://api.example.com")
    ///     Endpoint("/v1/data")
    ///     Header(.contentType, "application/json")
    ///     RequestBody.json(payload)
    ///     Authorization.custom { request in
    ///         let body = request.httpBody ?? Data()
    ///         let hash = SHA256.hash(data: body).description
    ///         request.setValue("SignedHash \(hash)",
    ///                         forHTTPHeaderField: "Authorization")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter authenticator: A closure that inspects and mutates the
    ///   in-progress request to apply custom authorization.
    static func custom(_ authenticator: @escaping (inout URLRequest) throws -> Void) -> some RequestBuildable {
        RequestBlock { state in
            try authenticator(&state.request)
        }
    }
}
