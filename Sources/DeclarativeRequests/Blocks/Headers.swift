import Foundation

/// Sets one or more HTTP headers on the request.
///
/// `Headers` mirrors the shape of ``Query`` and ``URLEncodedBody``: pick whichever
/// initializer fits the data you have.
///
/// - A single literal pair: `Headers("X-Trace-Id", "abc")`
/// - A single pair keyed by ``Header``: `Headers(.referer, "https://…")`
/// - A `[String: String]` dictionary: `Headers(["X-A": "1", "X-B": "2"])`
/// - A `[Header: String]` dictionary: `Headers([.accept: "application/json"])`
/// - An `Encodable` model whose top-level fields become headers:
///   `Headers(MyHeadersModel())`
///
/// All forms write through `URLRequest.setValue(_:forHTTPHeaderField:)`, so
/// existing values for the same name are overwritten. If you want
/// comma-appending behavior instead, use ``Header/addValue(_:)`` directly.
///
/// ```swift
/// let request = try URLRequest {
///     Headers(.accept, "application/json")
///     Headers([
///         .userAgent: "MyApp/1.0",
///         .acceptLanguage: "en",
///     ])
///     Headers(traceModel)
/// }
/// ```
public struct Headers: RequestBuildable, Sendable {
    let pairs: @Sendable (JSONEncoder) throws -> [(name: String, value: String)]

    /// Set a single header by literal name.
    ///
    /// Passing `nil` for `value` is a no-op (no header is written or cleared).
    ///
    /// - Parameters:
    ///   - name: The header name.
    ///   - value: The header value, or `nil` to skip writing.
    public init(_ name: String, _ value: String?) {
        let captured = (name, value)
        pairs = { _ in
            guard let value = captured.1 else { return [] }
            return [(captured.0, value)]
        }
    }

    /// Set a single header by ``Header`` enum case.
    ///
    /// ```swift
    /// Headers(.referer, "https://example.com")
    /// ```
    ///
    /// Passing `nil` for `value` is a no-op.
    ///
    /// - Parameters:
    ///   - header: The header to set.
    ///   - value: The header value, or `nil` to skip writing.
    public init(_ header: Header, _ value: String?) {
        self.init(header.rawValue, value)
    }

    /// Bulk-set headers from a `[String: String]` map.
    ///
    /// Keys are sorted alphabetically before being applied so the resulting
    /// `URLRequest` is deterministic regardless of the dictionary's iteration
    /// order.
    ///
    /// - Parameter map: Header name → value.
    public init(_ map: [String: String]) {
        let sorted = map
            .map { (name: $0.key, value: $0.value) }
            .sorted { $0.name < $1.name }
        pairs = { _ in sorted }
    }

    /// Bulk-set headers from a `[Header: String]` map.
    ///
    /// Equivalent to the `[String: String]` initializer but lets you key by the
    /// ``Header`` enum so common headers don't have to be spelled as strings.
    ///
    /// - Parameter map: Header → value.
    public init(_ map: [Header: String]) {
        let sorted = map
            .map { (name: $0.key.rawValue, value: $0.value) }
            .sorted { $0.name < $1.name }
        pairs = { _ in sorted }
    }

    /// Set headers from an `Encodable` model.
    ///
    /// The model is encoded with the request's ``RequestState/encoder`` and each
    /// top-level field becomes a header. Use `CodingKeys` (or a
    /// `keyEncodingStrategy` on a custom encoder) to map Swift property names
    /// to canonical header names like `User-Agent`:
    ///
    /// ```swift
    /// struct ApiHeaders: Codable {
    ///     let userAgent: String
    ///     let acceptLanguage: String
    ///
    ///     enum CodingKeys: String, CodingKey {
    ///         case userAgent = "User-Agent"
    ///         case acceptLanguage = "Accept-Language"
    ///     }
    /// }
    /// Headers(ApiHeaders(userAgent: "MyApp/1.0", acceptLanguage: "en"))
    /// ```
    ///
    /// `nil` optionals are omitted, primitives are stringified
    /// (`"42"`, `"true"`).
    ///
    /// - Parameter encodable: The model to encode.
    /// - Throws: ``DeclarativeRequestsError/encodingFailed(reason:)`` when
    ///   applied if the model has nested arrays or dictionaries — headers must
    ///   be flat.
    public init(_ encodable: any Encodable & Sendable) {
        pairs = { encoder in
            try EncodableHeaders(encodable: encodable, encoder: encoder).pairs
        }
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            for pair in try pairs(state.encoder) {
                state.request.setValue(pair.value, forHTTPHeaderField: pair.name)
            }
        }
    }
}
