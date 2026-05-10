import Foundation

/// Sets the `Authorization` header.
///
/// Use ``init(bearer:)`` for OAuth-style bearer tokens,
/// ``init(username:password:)`` for HTTP Basic credentials, or
/// ``init(_:)`` for custom authentication schemes that need to inspect the
/// request before computing the header value.
///
/// ```swift
/// // Bearer token:
/// Authorization(bearer: accessToken)
/// // → Authorization: Bearer <token>
///
/// // Basic auth:
/// Authorization(username: "alice", password: "s3cret")
/// // → Authorization: Basic YWxpY2U6czNjcmV0
///
/// // Custom authenticator — receives the request built so far:
/// Authorization { request in
///     let signature = hmac(request.allHTTPHeaderFields, secret: key)
///     request.setValue("HMAC \(signature)", forHTTPHeaderField: "Authorization")
/// }
/// ```
public struct Authorization: RequestBuildable {
    /// Create an `Authorization` block using HTTP Basic credentials.
    ///
    /// The credentials are joined with a colon, UTF-8 encoded, and Base64-encoded
    /// per RFC 7617.
    ///
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    public init(username: String, password: String) {
        let credentials = "\(username):\(password)"
        let data = Data(credentials.utf8)
        let base64 = data.base64EncodedString()
        let value = "Basic \(base64)"
        apply = { state in
            state.request.setValue(value, forHTTPHeaderField: Header.Field.authorization.rawValue)
        }
    }

    /// Create an `Authorization` block using a bearer token.
    ///
    /// - Parameter token: The bearer token. Written verbatim after `Bearer `.
    public init(bearer token: String) {
        let value = "Bearer \(token)"
        apply = { state in
            state.request.setValue(value, forHTTPHeaderField: Header.Field.authorization.rawValue)
        }
    }

    /// Create an `Authorization` block with a custom authenticator closure.
    ///
    /// The closure receives the in-progress `URLRequest` as an `inout` parameter
    /// after all preceding blocks have been applied. Use this for authentication
    /// schemes that derive credentials from the request itself — for example,
    /// HMAC signatures computed over headers or the request body.
    ///
    /// Place this block **after** all headers, query items, and body blocks so
    /// the request is fully formed when the closure runs.
    ///
    /// ```swift
    /// let request = try URLRequest {
    ///     Method.POST
    ///     BaseURL("https://api.example.com")
    ///     Endpoint("/v1/data")
    ///     Header(.contentType, "application/json")
    ///     RequestBody.json(payload)
    ///     Authorization { request in
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
    public init(_ authenticator: @escaping (inout URLRequest) throws -> Void) {
        apply = { state in
            try authenticator(&state.request)
        }
    }

    private let apply: RequestStateTransformClosure

    public var body: some RequestBuildable {
        RequestBlock(apply)
    }
}
