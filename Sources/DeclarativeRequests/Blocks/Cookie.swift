import Foundation

/// Adds a single cookie to the request's `Cookie` header.
///
/// Multiple `Cookie` declarations accumulate into a single
/// `Cookie: a=1; b=2` header.
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://api.example.com")
///     Cookie("session", token)
///     Cookie("locale", "en")
/// }
/// ```
public struct Cookie: RequestBuildable {
    /// Create a `Cookie` block.
    ///
    /// - Parameters:
    ///   - key: The cookie name.
    ///   - value: The cookie value.
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }

    let key: String
    let value: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.cookies[key] = value
        }
    }
}
