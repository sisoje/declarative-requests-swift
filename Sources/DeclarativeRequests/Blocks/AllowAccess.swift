/// Toggles which kinds of network connections the request is allowed to use.
///
/// Each case maps to one of the `allowsXAccess` flags on `URLRequest`. Use
/// these to opt out of expensive or constrained networks, or to require
/// cellular for certain workloads.
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://api.example.com")
///     Endpoint("/sync")
///     AllowAccess.cellular(true)
///     AllowAccess.expensiveNetwork(false)   // skip if user is on metered Wi-Fi
///     AllowAccess.constrainedNetwork(false) // skip in Low Data Mode
/// }
/// ```
public enum AllowAccess: RequestBuildable {
    /// Toggle `URLRequest.allowsCellularAccess`.
    /// - Parameter value: `true` to permit cellular, `false` to deny.
    case cellular(Bool)

    /// Toggle `URLRequest.allowsExpensiveNetworkAccess`.
    /// - Parameter value: `true` to permit expensive networks (e.g. cellular,
    ///   personal hotspot), `false` to deny.
    case expensiveNetwork(Bool)

    /// Toggle `URLRequest.allowsConstrainedNetworkAccess`.
    /// - Parameter value: `true` to permit constrained networks (Low Data
    ///   Mode), `false` to deny.
    case constrainedNetwork(Bool)

    /// Toggle `URLRequest.allowsUltraConstrainedNetworkAccess`. Only applied
    /// on platforms where the property exists; on older OS versions the block
    /// is a no-op.
    /// - Parameter value: `true` to permit ultra-constrained networks,
    ///   `false` to deny.
    case ultraConstrainedNetwork(Bool)

    public var body: some RequestBuildable {
        switch self {
        case .cellular(let value):
            RequestState[\.request.allowsCellularAccess, value]
        case .expensiveNetwork(let value):
            RequestState[\.request.allowsExpensiveNetworkAccess, value]
        case .constrainedNetwork(let value):
            RequestState[\.request.allowsConstrainedNetworkAccess, value]
        case .ultraConstrainedNetwork(let value):
            if #available(macOS 26.1, iOS 26.1, watchOS 26.1, tvOS 26.1, *) {
                RequestState[\.request.allowsUltraConstrainedNetworkAccess, value]
            }
        }
    }
}
