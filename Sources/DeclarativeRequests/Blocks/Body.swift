import Foundation

/// Attaches raw bytes (or a string) to the request body, optionally setting a content type.
///
/// Reach for `Body` when the typed body blocks (``JSONBody``, ``URLEncodedBody``,
/// ``MultipartBody``, ``StreamBody``) don't fit — pre-encoded payloads, binary
/// blobs, custom content types.
///
/// ```swift
/// // Pre-encoded JSON:
/// Body(jsonData, type: .JSON)
///
/// // GraphQL query as text:
/// Body("query { users { id } }", type: .PlainText)
///
/// // Binary upload, no content type:
/// Body(imageBytes)
/// ```
public struct Body: RequestBuildable {
    let data: Data
    let contentType: ContentType?

    /// Create a `Body` block from raw bytes.
    ///
    /// - Parameters:
    ///   - data: The body bytes.
    ///   - type: The content type to set on the request, or `nil` to leave any
    ///     existing `Content-Type` untouched.
    public init(_ data: Data, type: ContentType? = nil) {
        self.data = data
        contentType = type
    }

    /// Create a `Body` block from a string.
    ///
    /// The string is UTF-8 encoded.
    ///
    /// - Parameters:
    ///   - string: The body text.
    ///   - type: The content type to set. Defaults to ``ContentType/PlainText``.
    public init(_ string: String, type: ContentType = .PlainText) {
        data = Data(string.utf8)
        contentType = type
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = data
        }
        if let contentType {
            contentType
        }
    }
}
