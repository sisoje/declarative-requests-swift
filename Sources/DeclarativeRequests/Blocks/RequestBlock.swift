/// A leaf in the request DSL — a value that holds a raw state-transform closure.
///
/// `RequestBlock` is the primitive ``RequestBuildable`` that all other blocks
/// reduce to. You construct one in two ways:
///
/// 1. From a closure that mutates ``RequestState`` directly:
///
///    ```swift
///    let block = RequestBlock { state in
///        state.request.timeoutInterval = 30
///    }
///    ```
///
/// 2. From a `@RequestBuilder` closure, which lets you compose other blocks:
///
///    ```swift
///    let block = RequestBlock {
///        Method.POST
///        Endpoint("/users")
///        RequestBody.json(payload)
///    }
///    ```
///
/// The latter form is the entry point for building a request from a list of blocks
/// without going through ``URLRequest/init(url:cachePolicy:timeoutInterval:builder:)``.
///
/// > Important: ``body`` is unused for a `RequestBlock` (it is a leaf). Calling it
/// > traps; the result builder routes around it via the `transform` closure.
public struct RequestBlock: RequestBuildable {
    /// Lift a raw transform closure into a ``RequestBuildable``.
    ///
    /// - Parameter transform: A closure that mutates ``RequestState``.
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    /// Compose a series of blocks into a single ``RequestBlock``.
    ///
    /// ```swift
    /// let block = RequestBlock {
    ///     Method.GET
    ///     Endpoint("/users")
    /// }
    /// let request = try block.request
    /// ```
    ///
    /// - Parameter builder: A `@RequestBuilder` closure that produces the
    ///   composition.
    public init(@RequestBuilder builder: () -> any RequestBuildable) {
        transform = builder().transform
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}
