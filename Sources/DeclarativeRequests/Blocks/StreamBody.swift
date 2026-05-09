import Foundation

/// Streams the request body from an `InputStream` instead of a `Data` blob.
///
/// `StreamBody` lets you upload large payloads without loading them into memory.
/// `URLSession` reads from the stream as it sends, so the source can be a file
/// handle, a pipe, or any other on-demand byte producer.
///
/// ```swift
/// let request = try URLRequest {
///     Method.PUT
///     BaseURL("https://uploads.example.com")
///     Endpoint("/files/\(fileId)")
///     StreamBody(InputStream(url: largeFileURL))
///     ContentType.Stream
/// }
/// ```
///
/// The stream factory is `@autoclosure`, so the actual `InputStream` instance
/// is lazily produced when the block is applied. This matters because a stream
/// is single-use; if the request is built more than once, each build needs its
/// own stream.
public struct StreamBody: RequestBuildable, Sendable {
    let stream: @Sendable () throws -> InputStream?

    /// Create a `StreamBody` block.
    ///
    /// - Parameter str: An autoclosure that produces an `InputStream`. If it
    ///   returns `nil`, the block throws ``DeclarativeRequestsError/badStream``
    ///   when applied.
    public init(_ str: @Sendable @autoclosure @escaping () throws -> InputStream?) {
        stream = str
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard let stream = try stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = stream
        }
    }
}
