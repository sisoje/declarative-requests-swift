import Foundation

/// A typed identifier for an HTTP header.
///
/// The standard cases cover the most common headers and spell their canonical
/// names for you. Use ``custom(_:)`` for anything not in the list:
///
/// ```swift
/// Header.accept.setValue("application/json")
/// Header.userAgent.addValue("MyApp/1.0")
/// Header.custom("X-Trace-Id").setValue(traceId)
/// ```
///
/// `Header` is the underlying type for ``Headers`` and pairs with both
/// ``setValue(_:)`` (replaces any existing value) and ``addValue(_:)``
/// (appends, useful for headers that allow multiple comma-separated values).
public enum Header: Equatable, Hashable {
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
    /// - Parameter value: The exact header name to use.
    case custom(String)
}

public extension Header {
    /// The on-the-wire header name for this value.
    var rawValue: String {
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
        case .custom(let value): value
        }
    }

    /// Append a value to this header.
    ///
    /// Maps to `URLRequest.addValue(_:forHTTPHeaderField:)` — existing values
    /// are preserved and the new value is appended (typically as a
    /// comma-separated list).
    ///
    /// ```swift
    /// Header.accept.addValue("application/json")
    /// Header.accept.addValue("text/html")  // → "application/json,text/html"
    /// ```
    ///
    /// - Parameter value: The value to append.
    /// - Returns: A ``RequestBuildable`` that adds the value when applied.
    func addValue(_ value: String) -> some RequestBuildable {
        RequestBlock {
            $0.request.addValue(value, forHTTPHeaderField: rawValue)
        }
    }

    /// Set this header's value, replacing any existing value.
    ///
    /// Maps to `URLRequest.setValue(_:forHTTPHeaderField:)`.
    ///
    /// - Parameter value: The new value.
    /// - Returns: A ``RequestBuildable`` that sets the value when applied.
    func setValue(_ value: String) -> some RequestBuildable {
        RequestBlock {
            $0.request.setValue(value, forHTTPHeaderField: rawValue)
        }
    }
}
