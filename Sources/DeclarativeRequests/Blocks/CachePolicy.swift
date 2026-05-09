import Foundation

/// Sets the request's cache policy.
///
/// Maps to `URLRequest.cachePolicy`. Useful for opting individual requests out
/// of the shared `URLCache` (e.g. polling endpoints) or for forcing a fresh
/// fetch in response to user-initiated reloads.
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://api.example.com")
///     Endpoint("/feed")
///     CachePolicy(.reloadIgnoringLocalCacheData)
/// }
/// ```
public struct CachePolicy: RequestBuildable, Sendable {
    let policy: URLRequest.CachePolicy

    /// Create a `CachePolicy` block.
    ///
    /// - Parameter policy: The cache policy to apply.
    public init(_ policy: URLRequest.CachePolicy) {
        self.policy = policy
    }

    public var body: some RequestBuildable {
        RequestState[\.request.cachePolicy, policy]
    }
}
