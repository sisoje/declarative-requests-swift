/// Replaces the URL path with the supplied value.
///
/// `Endpoint` overwrites whatever path was set previously, including any path
/// component carried in by ``BaseURL``. If you want to *append* to the existing
/// path, use ``Path`` instead.
///
/// ```swift
/// // Path is replaced, not appended:
/// let request = try URLRequest {
///     BaseURL("https://api.example.com/v1")
///     Endpoint("/users")          // → https://api.example.com/users
/// }
/// ```
public struct Endpoint: RequestBuildable {
    /// Create an `Endpoint` block.
    ///
    /// - Parameter path: The full URL path, e.g. `"/users/123"`.
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuildable {
        RequestBlock {
            try $0.setPath(path)
        }
    }
}
