import Foundation

public extension URLSession {
    /// Build a request with the DSL and execute it.
    ///
    /// A one-call shortcut for `data(for:)` driven by a builder closure:
    ///
    /// ```swift
    /// let (data, response) = try await URLSession.shared.data {
    ///     Method.GET
    ///     BaseURL("https://api.example.com")
    ///     Path("/users/123")
    /// }
    /// ```
    ///
    /// - Parameter builder: A `@RequestBuilder` closure that produces the
    ///   request to send.
    /// - Returns: A tuple of the response body and the `URLResponse`.
    /// - Throws: Any error thrown while building the request, plus any error
    ///   thrown by `URLSession.data(for:)` itself.
    func data(@RequestBuilder _ builder: () -> any RequestBuildable) async throws -> (Data, URLResponse) {
        let request = try URLRequest(builder: builder)
        return try await data(for: request)
    }

    /// Build a request, execute it, and decode the response body into `T`.
    ///
    /// ```swift
    /// struct User: Decodable { let id: Int; let name: String }
    /// let user = try await URLSession.shared.decode(User.self) {
    ///     Method.GET
    ///     BaseURL("https://api.example.com")
    ///     Path("/users/123")
    /// }
    /// ```
    ///
    /// If you also need the `URLResponse`, call ``data(_:)`` and decode manually.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode the response body into.
    ///   - decoder: The `JSONDecoder` to use. Defaults to a fresh `JSONDecoder()`.
    ///   - builder: A `@RequestBuilder` closure that produces the request to
    ///     send.
    /// - Returns: The decoded value.
    /// - Throws: Any error thrown while building or sending the request, plus
    ///   any decoding error from the supplied decoder.
    func decode<T: Decodable>(
        _: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        @RequestBuilder _ builder: () -> any RequestBuildable
    ) async throws -> T {
        let (data, _) = try await self.data(builder)
        return try decoder.decode(T.self, from: data)
    }
}
