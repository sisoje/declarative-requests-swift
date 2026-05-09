import Foundation

/// JSON-encodes a value into the request body and sets `Content-Type: application/json`.
///
/// `JSONBody` uses the request's ``RequestState/encoder``, so any encoder
/// configuration you set there (date strategy, key strategy, output formatting)
/// is applied here.
///
/// ```swift
/// struct LoginRequest: Codable { let email: String; let password: String }
///
/// let request = try URLRequest {
///     Method.POST
///     BaseURL("https://api.example.com")
///     Endpoint("/login")
///     JSONBody(LoginRequest(email: email, password: password))
/// }
/// ```
public struct JSONBody: RequestBuildable, Sendable {
    /// Create a `JSONBody` block.
    ///
    /// - Parameter value: The value to encode. Must be both `Encodable` and
    ///   `Sendable` so the resulting block can cross actor boundaries.
    public init(_ value: any Encodable & Sendable) {
        self.value = value
    }

    let value: any Encodable & Sendable

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = try state.encoder.encode(value)
        }
        ContentType.JSON
    }
}
