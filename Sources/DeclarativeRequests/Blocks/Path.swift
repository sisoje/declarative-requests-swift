import Foundation

/// Appends path segments to the current URL path.
///
/// Unlike ``Endpoint``, which replaces the entire path, `Path` joins its
/// arguments with `/` and appends them to whatever path already exists on the
/// request — typically one set by ``BaseURL``. Leading and trailing slashes on
/// each segment are normalized so you can pass any mix of `"users"`,
/// `"/users"`, or `"/users/"` interchangeably.
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://api.example.com/v1")
///     Path("users", "\(userId)", "posts")
/// }
/// // https://api.example.com/v1/users/123/posts
/// ```
public struct Path: RequestBuildable {
    let segments: [String]

    /// Create a `Path` block from a variadic list of segments.
    ///
    /// - Parameter segments: One or more path segments. Each may include
    ///   embedded `/` characters; they are split and re-joined.
    public init(_ segments: String...) {
        self.segments = segments
    }

    /// Create a `Path` block from an array of segments.
    ///
    /// - Parameter segments: An array of path segments.
    public init(_ segments: [String]) {
        self.segments = segments
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            let pieces = segments.flatMap { $0.split(separator: "/").map(String.init) }
            guard !pieces.isEmpty else { return }
            let suffix = pieces.joined(separator: "/")
            let current = state.urlComponents?.path ?? ""
            let combined: String = if current.isEmpty || current == "/" {
                "/" + suffix
            } else {
                current + (current.hasSuffix("/") ? "" : "/") + suffix
            }
            try state.setPath(combined)
        }
    }
}
