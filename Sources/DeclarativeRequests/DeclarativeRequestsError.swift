import Foundation

/// Errors thrown while building a request through the DSL.
///
/// All cases conform to `LocalizedError` so they produce a useful
/// `localizedDescription` when surfaced to users or logged.
public enum DeclarativeRequestsError: Error, Equatable, Sendable, LocalizedError {
    /// The request URL is missing or could not be constructed from the inputs
    /// declared in the builder.
    ///
    /// Typically thrown by ``BaseURL`` when given an invalid string, or by
    /// ``Endpoint`` / ``Path`` when no base URL has been set.
    case badUrl

    /// A ``StreamBody`` could not produce or open its `InputStream`.
    case badStream

    /// A ``MultipartBody`` could not be assembled — most often because a
    /// ``MultipartPart/file(name:fileURL:type:filename:)`` part references a
    /// path that cannot be read.
    ///
    /// - Parameter reason: A human-readable description of what went wrong.
    case badMultipart(reason: String)

    /// Encoding a model into headers, query items, or a body failed.
    ///
    /// - Parameter reason: A human-readable description of what went wrong.
    case encodingFailed(reason: String)

    /// A localized, human-readable description of the error suitable for
    /// surfacing to end users or writing to logs.
    public var errorDescription: String? {
        switch self {
        case .badUrl:
            "The URL is missing or could not be constructed."
        case .badStream:
            "The input stream could not be opened."
        case .badMultipart(let reason):
            "Multipart body could not be built: \(reason)"
        case .encodingFailed(let reason):
            "Encoding failed: \(reason)"
        }
    }
}
