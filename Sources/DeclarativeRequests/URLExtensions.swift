import Foundation

public extension URL {
    /// Build a `URLRequest` rooted at this URL using the request DSL.
    ///
    /// This is the most ergonomic entry point when you already have a `URL` value:
    ///
    /// ```swift
    /// let api = URL(string: "https://api.example.com")!
    /// let request = try api.buildRequest {
    ///     Method.GET
    ///     Path("v1", "users", userId)
    ///     Header.accept.setValue("application/json")
    /// }
    /// ```
    ///
    /// The receiver is implicitly used as the ``BaseURL``; further blocks layer
    /// path components, query items, headers, and body content on top.
    ///
    /// - Parameter builder: A `@RequestBuilder` closure that declares the
    ///   request's components.
    /// - Returns: The built `URLRequest`.
    /// - Throws: ``DeclarativeRequestsError`` if any block fails to apply.
    func buildRequest(@RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
        try RequestBlock {
            builder()
            BaseURL(self)
        }.request
    }
}

/// Build a `URLRequest` from a string base URL plus a request DSL block.
///
/// A convenience that combines `URL(string:)` with
/// ``Foundation/URL/buildRequest(builder:)``:
///
/// ```swift
/// let request = try URL("https://api.example.com") {
///     Method.POST
///     Endpoint("/login")
///     JSONBody(credentials)
/// }
/// ```
///
/// - Parameters:
///   - string: The base URL as a string. Must parse via `URL(string:)`.
///   - builder: A `@RequestBuilder` closure that declares the request's components.
/// - Returns: The built `URLRequest`.
/// - Throws: ``DeclarativeRequestsError/badUrl`` if `string` cannot be parsed,
///   or any error thrown while applying the builder.
public func URL(_ string: String, @RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
    guard let url = Foundation.URL(string: string) else {
        throw DeclarativeRequestsError.badUrl
    }
    return try url.buildRequest(builder: builder)
}

public extension URLRequest {
    /// Build a `URLRequest` from a request DSL block.
    ///
    /// Equivalent to `RequestBlock { … }.request`. Use this when you want to
    /// declare the URL inside the builder via ``BaseURL``:
    ///
    /// ```swift
    /// let request = try URLRequest {
    ///     Method.GET
    ///     BaseURL("https://api.example.com")
    ///     Endpoint("/health")
    /// }
    /// ```
    ///
    /// If you already have a `URL` value, ``Foundation/URL/buildRequest(builder:)``
    /// is usually a cleaner fit.
    ///
    /// - Parameter builder: A `@RequestBuilder` closure that declares the
    ///   request's components.
    /// - Throws: ``DeclarativeRequestsError`` if any block fails to apply.
    init(@RequestBuilder _ builder: () -> any RequestBuildable) throws {
        self = try RequestBlock(builder: builder).request
    }
}
