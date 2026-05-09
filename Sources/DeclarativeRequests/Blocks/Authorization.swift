import Foundation

/// Sets the `Authorization` header.
///
/// Use ``init(bearer:)`` for OAuth-style bearer tokens or
/// ``init(username:password:)`` for HTTP Basic credentials.
///
/// ```swift
/// // Bearer token:
/// Authorization(bearer: accessToken)
/// // → Authorization: Bearer <token>
///
/// // Basic auth:
/// Authorization(username: "alice", password: "s3cret")
/// // → Authorization: Basic YWxpY2U6czNjcmV0
/// ```
public struct Authorization: RequestBuildable, Sendable {
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
        value = "Basic \(base64)"
    }

    /// Create an `Authorization` block using a bearer token.
    ///
    /// - Parameter token: The bearer token. Written verbatim after `Bearer `.
    public init(bearer token: String) {
        value = "Bearer \(token)"
    }

    let value: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request.setValue(value, forHTTPHeaderField: Header.authorization.rawValue)
        }
    }
}
