import Foundation

/// Toggles automatic cookie handling for the request.
///
/// Maps to `URLRequest.httpShouldHandleCookies`. When `false`, `URLSession`
/// won't read or write cookies for this request via the shared
/// `HTTPCookieStorage`. Useful when you're managing cookies manually (e.g.
/// for tests, or for an authentication flow that uses out-of-band tokens).
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://api.example.com")
///     Path("/oauth/token")
///     HTTPShouldHandleCookies(false)
/// }
/// ```
public struct HTTPShouldHandleCookies: RequestBuildable {
    let value: Bool

    /// Create an `HTTPShouldHandleCookies` block.
    ///
    /// - Parameter value: `true` to use the shared cookie storage, `false` to
    ///   bypass it.
    public init(_ value: Bool) {
        self.value = value
    }

    public var body: some RequestBuildable {
        RequestState[\.request.httpShouldHandleCookies, value]
    }
}
