import Foundation

/// Resolves a path reference against the request's current URL using RFC 3986
/// reference resolution — the same algorithm as Python's
/// `urllib.parse.urljoin` or JavaScript's `new URL(reference, base)`.
///
/// `Path` is for *navigating* the URL: it appends to, traverses through, or
/// resets the path that's already on the request. To replace the path
/// outright with a literal value, use ``Endpoint``.
///
/// ```swift
/// // Relative — appends:
/// BaseURL("https://api.example.com/v1") + Path("users", "\(id)")
/// //   → https://api.example.com/v1/users/123
///
/// // Absolute — resets to root:
/// BaseURL("https://api.example.com/v1") + Path("/health")
/// //   → https://api.example.com/health
///
/// // Dot-traversal — `..` and `.` are collapsed:
/// BaseURL("https://api.example.com/a/b") + Path("../c")
/// //   → https://api.example.com/a/c
/// ```
///
/// Variadic segments are joined with `/`, so a list of pieces and a single
/// pre-joined string are interchangeable:
///
/// ```swift
/// Path("v1", "users", "\(id)")          // → "v1/users/123"
/// Path("v1/users/\(id)")                // → "v1/users/123" (same)
/// ```
///
/// > Note: The base path is treated as a directory, so `BaseURL("…/v1")` and
/// > `BaseURL("…/v1/")` both append cleanly. (Strict RFC 3986 would replace
/// > the last segment of a non-slash-terminated base.) A leading `/` on the
/// > reference always means *absolute* — `Path("/users")` and `Path("users")`
/// > are not equivalent.
public struct Path: RequestBuildable {
    let reference: String

    /// Create a `Path` block from a variadic list of segments. Segments are
    /// joined with `/` to form the reference.
    public init(_ segments: String...) {
        self.init(segments)
    }

    /// Create a `Path` block from an array of segments.
    public init(_ segments: [String]) {
        reference = segments.joined(separator: "/")
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard !reference.isEmpty else { return }
            guard let base = state.request.url,
                  var directoryBase = URLComponents(url: base, resolvingAgainstBaseURL: true)
            else {
                throw DeclarativeRequestsError.badUrl
            }
            if !directoryBase.path.hasSuffix("/") {
                directoryBase.path += "/"
            }
            var ref = URLComponents()
            ref.path = reference
            guard let resolutionBase = directoryBase.url,
                  let resolved = ref.url(relativeTo: resolutionBase)?.absoluteURL,
                  let resolvedComponents = URLComponents(url: resolved, resolvingAgainstBaseURL: true)
            else {
                throw DeclarativeRequestsError.badUrl
            }
            try state.setPath(resolvedComponents.path)
        }
    }
}
