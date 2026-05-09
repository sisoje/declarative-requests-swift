import Foundation

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
    /// If you already have a `URL` value, ``init(url:cachePolicy:timeoutInterval:builder:)``
    /// is usually a cleaner fit.
    ///
    /// - Parameter builder: A `@RequestBuilder` closure that declares the
    ///   request's components.
    /// - Throws: ``DeclarativeRequestsError`` if any block fails to apply.
    init(@RequestBuilder _ builder: () -> any RequestBuildable) throws {
        self = try RequestBlock(builder: builder).request
    }

    /// Build a `URLRequest` rooted at `url` and shaped by a request DSL block.
    ///
    /// Mirrors the standard `URLRequest(url:cachePolicy:timeoutInterval:)`
    /// initializer with a trailing `@RequestBuilder` closure that layers
    /// further blocks (path, query, headers, body, …) on top:
    ///
    /// ```swift
    /// let api = URL(string: "https://api.example.com")!
    /// let request = try URLRequest(url: api) {
    ///     Method.GET
    ///     Path("v1", "users", userId)
    ///     Header.accept.setValue("application/json")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - url: The starting URL.
    ///   - cachePolicy: The cache policy. Defaults to `.useProtocolCachePolicy`.
    ///   - timeoutInterval: The timeout interval in seconds. Defaults to `60`.
    ///   - builder: A `@RequestBuilder` closure that declares the request's
    ///     components. Blocks inside may override the supplied URL, cache
    ///     policy, or timeout.
    /// - Throws: ``DeclarativeRequestsError`` if any block fails to apply.
    init(
        url: URL,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0,
        @RequestBuilder builder: () -> any RequestBuildable
    ) throws {
        let initial = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        let state = RequestState(request: initial)
        try RequestBlock(builder: builder).transform(state)
        self = state.request
    }

    /// Build a `URLRequest` from a base URL string and a request DSL block.
    ///
    /// Convenience for callers who don't want to construct a `URL` themselves:
    ///
    /// ```swift
    /// let request = try URLRequest(string: "https://api.example.com") {
    ///     Method.POST
    ///     Endpoint("/login")
    ///     JSONBody(credentials)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - string: The base URL as a string. Must parse via `URL(string:)`.
    ///   - cachePolicy: The cache policy. Defaults to `.useProtocolCachePolicy`.
    ///   - timeoutInterval: The timeout interval in seconds. Defaults to `60`.
    ///   - builder: A `@RequestBuilder` closure that declares the request's
    ///     components.
    /// - Throws: ``DeclarativeRequestsError/badUrl`` if `string` cannot be
    ///   parsed, or any error thrown while applying the builder.
    init(
        string: String,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 60.0,
        @RequestBuilder builder: () -> any RequestBuildable
    ) throws {
        guard let url = URL(string: string) else {
            throw DeclarativeRequestsError.badUrl
        }
        try self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval, builder: builder)
    }
}
