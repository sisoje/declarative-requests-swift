import Foundation

/// One HTTP header line on the request.
///
/// Each `Header(...)` block corresponds visually to one `Name: value` line in
/// the raw HTTP request:
///
/// ```
/// Accept: application/json
/// User-Agent: MyApp/1.0
/// X-Trace-Id: abc123
/// ```
///
/// becomes
///
/// ```swift
/// Header(.accept, "application/json")
/// Header(.userAgent, "MyApp/1.0")
/// Header("X-Trace-Id", "abc123")
/// ```
///
/// By default each block *replaces* any existing value for that header
/// (`URLRequest.setValue(_:forHTTPHeaderField:)`). Pass `mode: .add` to
/// *append* instead (`URLRequest.addValue(_:forHTTPHeaderField:)`), which is
/// useful for headers like `Accept` that allow comma-separated values:
///
/// ```swift
/// Header(.accept, "application/json")
/// Header(.accept, "text/html", mode: .add)   // → "application/json,text/html"
/// ```
///
/// For bulk declarations, pass a dictionary or an `Encodable` model — the
/// expansion still produces one HTTP-line per entry, just written once:
///
/// ```swift
/// Header([.accept: "application/json", .userAgent: "MyApp/1.0"])
/// Header(myHeadersModel)
/// ```
public struct Header: RequestBuildable {
    /// A typed identifier for an HTTP header.
    ///
    /// Standard cases spell their canonical names; use `.custom(_:)` for
    /// anything not in the list. Use ``rawValue`` to get the on-the-wire name.
    public enum Field: Equatable, Hashable {
        /// `Content-Type`
        case contentType
        /// `Accept`
        case accept
        /// `Authorization`
        case authorization
        /// `User-Agent`
        case userAgent
        /// `Origin`
        case origin
        /// `Cookie`
        case cookie
        /// `Referer`
        case referer
        /// `Host`
        case host
        /// `Accept-Language`
        case acceptLanguage
        /// `Accept-Encoding`
        case acceptEncoding
        /// A header name not covered by a dedicated case.
        case custom(String)

        /// The on-the-wire header name for this value.
        public var rawValue: String {
            switch self {
            case .contentType: "Content-Type"
            case .accept: "Accept"
            case .authorization: "Authorization"
            case .userAgent: "User-Agent"
            case .origin: "Origin"
            case .cookie: "Cookie"
            case .referer: "Referer"
            case .host: "Host"
            case .acceptLanguage: "Accept-Language"
            case .acceptEncoding: "Accept-Encoding"
            case let .custom(value): value
            }
        }
    }

    /// Whether to replace an existing header value or append to it.
    public enum Mode {
        /// `URLRequest.setValue(_:forHTTPHeaderField:)` — replace any existing value.
        case set
        /// `URLRequest.addValue(_:forHTTPHeaderField:)` — append (typically as a comma-separated list).
        case add
    }

    let apply: (RequestState) throws -> Void

    init(_ apply: @escaping (RequestState) throws -> Void) {
        self.apply = apply
    }

    public var body: some RequestBuildable {
        RequestBlock(apply)
    }
}

public extension Header {
    /// Set (or append, with `mode: .add`) a single header by ``Field``.
    ///
    /// Passing `nil` for `value` is a no-op (no header is written or cleared).
    init(_ field: Field, _ value: String?, mode: Mode = .set) {
        self.init(field.rawValue, value, mode: mode)
    }

    /// Set (or append, with `mode: .add`) a single header by literal name.
    ///
    /// Passing `nil` for `value` is a no-op.
    init(_ name: String, _ value: String?, mode: Mode = .set) {
        self.init { state in
            guard let value else { return }
            Header.write(name: name, value: value, mode: mode, state: state)
        }
    }

    /// Bulk-set headers from a `[Field: String]` map. Keys are sorted
    /// alphabetically before being applied so the resulting `URLRequest` is
    /// deterministic regardless of the dictionary's iteration order.
    init(_ map: [Field: String], mode: Mode = .set) {
        let pairs = map
            .map { (name: $0.key.rawValue, value: $0.value) }
            .sorted { $0.name < $1.name }
        self.init { state in
            for pair in pairs {
                Header.write(name: pair.name, value: pair.value, mode: mode, state: state)
            }
        }
    }

    /// Bulk-set headers from a `[String: String]` map. Keys are sorted
    /// alphabetically before being applied.
    init(_ map: [String: String], mode: Mode = .set) {
        let pairs = map
            .map { (name: $0.key, value: $0.value) }
            .sorted { $0.name < $1.name }
        self.init { state in
            for pair in pairs {
                Header.write(name: pair.name, value: pair.value, mode: mode, state: state)
            }
        }
    }

    /// Bulk-set headers from an `Encodable` model. Each top-level field
    /// becomes a header. Use `CodingKeys` (or a `keyEncodingStrategy` on a
    /// custom encoder) to map Swift property names to canonical header names
    /// like `User-Agent`:
    ///
    /// ```swift
    /// struct ApiHeaders: Codable {
    ///     let userAgent: String
    ///     let acceptLanguage: String
    ///     enum CodingKeys: String, CodingKey {
    ///         case userAgent = "User-Agent"
    ///         case acceptLanguage = "Accept-Language"
    ///     }
    /// }
    /// Header(ApiHeaders(userAgent: "MyApp/1.0", acceptLanguage: "en"))
    /// ```
    ///
    /// `nil` optionals are omitted; primitives are stringified
    /// (`"42"`, `"true"`).
    ///
    /// - Throws: ``DeclarativeRequestsError/encodingFailed(reason:)`` when
    ///   applied if the model has nested arrays or dictionaries — headers
    ///   must be flat.
    init(_ encodable: any Encodable, mode: Mode = .set) {
        self.init { state in
            let pairs = try EncodableHeaderPairs(encodable: encodable, encoder: state.encoder).pairs
            for pair in pairs {
                Header.write(name: pair.name, value: pair.value, mode: mode, state: state)
            }
        }
    }

    private static func write(name: String, value: String, mode: Mode, state: RequestState) {
        switch mode {
        case .set:
            state.request.setValue(value, forHTTPHeaderField: name)
        case .add:
            state.request.addValue(value, forHTTPHeaderField: name)
        }
    }
}

// MARK: - Encodable → header pairs

/// Encodes a model into a flat list of HTTP header (name, value) pairs.
/// Throws if the encoded payload isn't a flat JSON object — headers cannot
/// carry nested arrays or dictionaries.
private struct EncodableHeaderPairs {
    let encodable: any Encodable
    let encoder: JSONEncoder

    var pairs: [(name: String, value: String)] {
        get throws {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data)
            guard let dict = json as? [String: Any] else {
                throw DeclarativeRequestsError.encodingFailed(
                    reason: "Headers model must encode to a JSON object"
                )
            }
            return try dict
                .sorted { $0.key < $1.key }
                .compactMap { entry in
                    if entry.value is NSNull { return nil }
                    if entry.value is [Any] || entry.value is [String: Any] {
                        throw DeclarativeRequestsError.encodingFailed(
                            reason: "Header '\(entry.key)' has nested value; headers must be flat"
                        )
                    }
                    return (name: entry.key, value: stringValue(of: entry.value))
                }
        }
    }

    private func stringValue(of any: Any) -> String {
        if let str = any as? String { return str }
        if let bool = any as? Bool { return String(describing: bool) }
        return String(describing: any)
    }
}
