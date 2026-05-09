import Foundation

/// The mutable scratchpad threaded through every block while a request is being built.
///
/// `RequestState` holds the in-progress `URLRequest` plus the encoder and decoder used
/// by Encodable-driven blocks (``JSONBody``, ``URLEncodedBody``, ``Query``, ``Headers``).
/// Each ``RequestBuildable`` mutates this state through a
/// ``RequestStateTransformClosure`` and the next block sees the result.
///
/// You typically don't construct a `RequestState` yourself — call
/// ``RequestBuildable/request`` (or one of the convenience entry points like
/// ``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)``) and the framework manages the lifecycle.
/// Constructing one explicitly is useful for tests:
///
/// ```swift
/// let state = RequestState()
/// try block.transform(state)
/// XCTAssertEqual(state.request.httpMethod, "POST")
/// ```
///
/// ## Concurrency
///
/// `RequestState` is `@unchecked Sendable`. Each instance is meant to be created and
/// mutated within a single synchronous build; the library never shares one across
/// concurrency domains. The `Sendable` conformance exists so that ``RequestBlock``'s
/// transform closures (which capture the state-typed parameter) can themselves be
/// `@Sendable` and used inside actor-isolated code.
public final class RequestState: @unchecked Sendable {
    /// An empty placeholder URL used when no ``BaseURL`` has been declared yet.
    ///
    /// `URLComponents().url` is non-nil on every Foundation platform we target. The
    /// fallback inside this constant is a safety net so the value can be initialized
    /// without an inline force-unwrap.
    public static let placeholderURL: URL = {
        if let url = URLComponents().url { return url }
        guard let fallback = URL(string: "") else {
            preconditionFailure("Foundation could not produce an empty placeholder URL")
        }
        return fallback
    }()

    /// Create a new state.
    ///
    /// - Parameters:
    ///   - request: The starting `URLRequest`. Defaults to a request rooted at
    ///     ``placeholderURL``.
    ///   - encoder: The `JSONEncoder` used by Encodable-driven blocks.
    ///   - decoder: The `JSONDecoder` made available to extensions like
    ///     ``Foundation/URLSession/decode(_:decoder:_:)``.
    public init(
        request: URLRequest = URLRequest(url: RequestState.placeholderURL),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.request = request
        self.encoder = encoder
        self.decoder = decoder
    }

    /// The in-progress request being built. Blocks read and mutate this directly.
    public var request: URLRequest

    /// The encoder used to serialize Encodable values inside ``JSONBody``,
    /// ``URLEncodedBody``, ``Query``, and ``Headers``.
    public var encoder: JSONEncoder

    /// A decoder you can pre-configure here so response-decoding helpers like
    /// ``Foundation/URLSession/decode(_:decoder:_:)`` pick it up.
    public var decoder: JSONDecoder

    /// The cookies currently encoded into the `Cookie` header, parsed lazily.
    ///
    /// Reads parse the existing header. Writes serialize the dictionary back as a
    /// `name=value; …` string. Setting an empty dictionary clears the header.
    public var cookies: [String: String] {
        get {
            request.value(forHTTPHeaderField: Header.cookie.rawValue)?
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
            request.setValue(value, forHTTPHeaderField: Header.cookie.rawValue)
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

    var encodedBodyItems: [URLQueryItem] {
        get {
            request.httpBody.flatMap { bodyData in
                var comp = URLComponents()
                comp.percentEncodedQuery = String(decoding: bodyData, as: UTF8.self)
                return comp.queryItems
            } ?? []
        }
        set {
            var comp = URLComponents()
            comp.queryItems = newValue
            request.httpBody = comp.percentEncodedQuery?.data(using: .utf8)
        }
    }
}

/// Wraps a key path so it can be captured by `@Sendable` closures. Key paths into
/// non-final classes are not `Sendable` in the stdlib yet, but the ones used here are
/// simple stored-property paths that are safe to share.
private struct UncheckedSendableKeyPath<Root, Value>: @unchecked Sendable {
    let keyPath: ReferenceWritableKeyPath<Root, Value>
}

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
    static subscript<T: Sendable>(_ keyPath: ReferenceWritableKeyPath<RequestState, T>, _ value: @autoclosure @escaping @Sendable () throws -> T) -> RequestBlock {
        let wrapped = UncheckedSendableKeyPath(keyPath: keyPath)
        return RequestBlock { state in
            state[keyPath: wrapped.keyPath] = try value()
        }
    }
}
