import Foundation

/// The mutable scratchpad threaded through every block while a request is being built.
///
/// `RequestState` holds the in-progress `URLRequest` plus the encoder used by
/// Encodable-driven blocks (``RequestBody/json(_:)``, ``RequestBody/urlEncoded(_:)-(any_Encodable)``,
/// ``Query``, ``Header/init(_:mode:)-(any_Encodable,_)``). Each ``RequestBuildable``
/// mutates this state through a ``RequestStateTransformClosure`` and the next
/// block sees the result.
///
/// You typically don't construct a `RequestState` yourself — call
/// ``RequestBuildable/request`` (or one of the convenience entry points like
/// ``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)``) and the
/// framework manages the lifecycle. Constructing one explicitly is useful for
/// tests:
///
/// ```swift
/// let state = RequestState()
/// try block.transform(state)
/// XCTAssertEqual(state.request.httpMethod, "POST")
/// ```
public final class RequestState {
    /// Create a new state.
    ///
    /// - Parameters:
    ///   - request: The starting `URLRequest`. Defaults to a request rooted at
    ///     a placeholder URL that ``BaseURL`` is expected to replace.
    ///   - encoder: The `JSONEncoder` used by Encodable-driven blocks.
    public init(
        request: URLRequest = URLRequest(url: placeholderURL),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.request = request
        self.encoder = encoder
    }

    /// The in-progress request being built. Blocks read and mutate this directly.
    public var request: URLRequest

    /// The encoder used to serialize Encodable values inside body and header blocks.
    public var encoder: JSONEncoder

    /// The cookies currently encoded into the `Cookie` header, parsed lazily.
    ///
    /// Reads parse the existing header. Writes serialize the dictionary back as a
    /// `name=value; …` string. Setting an empty dictionary clears the header.
    public var cookies: [String: String] {
        get {
            request.value(forHTTPHeaderField: Header.Field.cookie.rawValue)?
                .split(separator: ";")
                .reduce(into: [:]) { result, component in
                    let parts = component.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        let key = parts[0].trimmingCharacters(in: .whitespaces)
                        let value = parts[1].trimmingCharacters(in: .whitespaces)
                        result[key] = value
                    }
                } ?? [:]
        }
        set {
            let cookieString = newValue
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "; ")
            let value = cookieString.isEmpty ? nil : cookieString
            request.setValue(value, forHTTPHeaderField: Header.Field.cookie.rawValue)
        }
    }

    var urlComponents: URLComponents? {
        request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }
    }

    func setBaseURL(_ url: URL) throws {
        guard let url = urlComponents?.url(relativeTo: url) else {
            throw DeclarativeRequestsError.badUrl
        }
        request.url = url
    }

    func setPath(_ path: String) throws {
        var urlComponents = urlComponents
        urlComponents?.path = path
        guard let url = urlComponents?.url else {
            throw DeclarativeRequestsError.badUrl
        }
        request.url = url
    }

    var queryItems: [URLQueryItem] {
        get {
            urlComponents?.queryItems ?? []
        }
        set {
            var urlComponents = urlComponents
            urlComponents?.queryItems = newValue
            request.url = urlComponents?.url
        }
    }
}

/// An empty placeholder URL used by ``RequestState`` and
/// ``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)`` when no URL
/// has been supplied — a ``BaseURL`` block in the builder is expected to
/// replace it.
public let placeholderURL = URLComponents().url!

public extension RequestState {
    /// Generate a ``RequestBlock`` that writes a value through a key path on
    /// ``RequestState``.
    ///
    /// This subscript is the primary way internal blocks like ``Method`` and
    /// ``Timeout`` express their transform without writing a closure each time:
    ///
    /// ```swift
    /// public var body: some RequestBuildable {
    ///     RequestState[\.request.timeoutInterval, interval]
    /// }
    /// ```
    ///
    /// You can use it the same way to write your own one-liner blocks.
    ///
    /// - Parameters:
    ///   - keyPath: A writable key path into ``RequestState`` (typically into a
    ///     property of the wrapped `URLRequest`).
    ///   - value: The value to assign. The closure is `@autoclosure` so the
    ///     expression is evaluated lazily and may `throw`.
    /// - Returns: A ``RequestBlock`` that performs the assignment when applied.
    static subscript<T>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: @autoclosure @escaping () throws -> T) -> RequestBlock {
        RequestBlock { state in
            state[keyPath: keyPath] = try value()
        }
    }
}
