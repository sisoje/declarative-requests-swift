import Foundation

/// The HTTP request body — one block, several factories.
///
/// `RequestBody` is the single block for everything that goes after the empty line
/// in a raw HTTP request. The factory you pick decides how the bytes are
/// produced and what `Content-Type` (if any) is set on the request:
///
/// ```swift
/// // Raw bytes (or string) with optional Content-Type:
/// RequestBody.data(jpegData, type: .JPEG)
/// RequestBody.string("hello")                              // text/plain
///
/// // Encodable → JSON, sets Content-Type: application/json
/// RequestBody.json(LoginRequest(email: e, password: p))
///
/// // application/x-www-form-urlencoded
/// RequestBody.urlEncoded([
///     URLQueryItem(name: "grant_type", value: "password"),
///     URLQueryItem(name: "username", value: "alice"),
/// ])
/// RequestBody.urlEncoded(loginForm)                        // any Encodable / [String:String]
///
/// // Stream the body from an InputStream:
/// RequestBody.stream(InputStream(url: largeFileURL))
///
/// // multipart/form-data:
/// RequestBody.multipart {
///     MultipartPart.field(name: "title", value: "Vacation")
///     MultipartPart.file(name: "video", fileURL: clipURL, type: .MP4)
/// }
/// // …or streaming for huge files:
/// RequestBody.multipart(strategy: .streamed()) { … }
/// ```
///
/// Like every other request property, the body is *replaced* if multiple
/// `RequestBody.*` blocks are declared — the last one wins.
public struct RequestBody: RequestBuildable {
    let apply: (RequestState) throws -> Void

    init(_ apply: @escaping (RequestState) throws -> Void) {
        self.apply = apply
    }

    public var body: some RequestBuildable {
        RequestBlock(apply)
    }
}

public extension RequestBody {
    /// A `Data` body, optionally tagged with a `Content-Type`.
    ///
    /// - Parameters:
    ///   - data: The body bytes.
    ///   - type: The content type to set on the request, or `nil` to leave any
    ///     existing `Content-Type` untouched.
    static func data(_ data: Data, type: ContentType? = nil) -> RequestBody {
        RequestBody { state in
            state.request.httpBody = data
            if let type {
                state.request.setValue(type.rawValue, forHTTPHeaderField: Header.Field.contentType.rawValue)
            }
        }
    }

    /// A UTF-8 string body. Defaults to `Content-Type: text/plain`.
    ///
    /// - Parameters:
    ///   - string: The body text.
    ///   - type: The content type to set. Defaults to ``ContentType/PlainText``.
    static func string(_ string: String, type: ContentType = .PlainText) -> RequestBody {
        .data(Data(string.utf8), type: type)
    }

    /// JSON-encodes `value` into the body and sets `Content-Type: application/json`.
    ///
    /// Uses the request's ``RequestState/encoder``, so any encoder configuration
    /// (date strategy, key strategy, output formatting) you set there is applied.
    ///
    /// - Parameter value: The value to encode.
    static func json(_ value: any Encodable) -> RequestBody {
        RequestBody { state in
            state.request.httpBody = try state.encoder.encode(value)
            state.request.setValue(ContentType.JSON.rawValue, forHTTPHeaderField: Header.Field.contentType.rawValue)
        }
    }

    /// A `application/x-www-form-urlencoded` body built from explicit query items.
    ///
    /// Items are encoded in the supplied order; duplicate names are preserved
    /// (`a=1&a=2&b=3`).
    ///
    /// - Parameter items: The form items to encode.
    static func urlEncoded(_ items: [URLQueryItem]) -> RequestBody {
        RequestBody { state in
            var components = URLComponents()
            components.queryItems = items
            state.request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            state.request.setValue(ContentType.URLEncoded.rawValue, forHTTPHeaderField: Header.Field.contentType.rawValue)
        }
    }

    /// A `application/x-www-form-urlencoded` body built from an `Encodable` model.
    ///
    /// Top-level fields become form items. Nested arrays use bracket-indexed
    /// keys (`tags[0]=a&tags[1]=b`). Booleans serialize as `"true"`/`"false"`.
    /// Dictionary keys are emitted in alphabetical order so the body is
    /// deterministic.
    ///
    /// `[String: String]` literals also satisfy `Encodable`, so this overload
    /// covers the common dict case:
    ///
    /// ```swift
    /// RequestBody.urlEncoded(["grant_type": "password", "username": "alice"])
    /// ```
    ///
    /// - Parameter encodable: The model to encode.
    static func urlEncoded(_ encodable: any Encodable) -> RequestBody {
        RequestBody { state in
            let items = try EncodableQueryItems(encodable: encodable, encoder: state.encoder).items
            var components = URLComponents()
            components.queryItems = items
            state.request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            state.request.setValue(ContentType.URLEncoded.rawValue, forHTTPHeaderField: Header.Field.contentType.rawValue)
        }
    }

    /// Stream the body from an `InputStream`. Sets `httpBodyStream`.
    ///
    /// The stream factory is `@autoclosure`, so the actual `InputStream`
    /// instance is lazily produced when the block is applied — important
    /// because a stream is single-use; if the request is built more than once,
    /// each build needs its own stream.
    ///
    /// ```swift
    /// RequestBody.stream(InputStream(url: largeFileURL))
    /// ```
    ///
    /// Note: this does *not* set `Content-Type` — pair it with a `Header(...)`
    /// declaration if the server needs one.
    ///
    /// - Parameter stream: An autoclosure that produces an `InputStream`. If it
    ///   returns `nil`, the block throws ``DeclarativeRequestsError/badStream``
    ///   when applied.
    static func stream(_ stream: @autoclosure @escaping () throws -> InputStream?) -> RequestBody {
        RequestBody { state in
            guard let s = try stream() else {
                throw DeclarativeRequestsError.badStream
            }
            state.request.httpBodyStream = s
        }
    }
}
