import Foundation

/// Sets the request's network service type, hinting at the kind of traffic it represents.
///
/// Maps to `URLRequest.networkServiceType`. The system uses this hint to make
/// scheduling and quality-of-service decisions — e.g. `.background` lets the
/// OS defer the request when the device is on a metered connection, while
/// `.responsiveData` indicates user-initiated traffic that should be
/// prioritized.
///
/// ```swift
/// let request = try URLRequest {
///     BaseURL("https://uploads.example.com")
///     Endpoint("/sync")
///     NetworkServiceType(.background)
/// }
/// ```
public struct NetworkServiceType: RequestBuildable {
    let type: URLRequest.NetworkServiceType

    /// Create a `NetworkServiceType` block.
    ///
    /// - Parameter type: The service type to apply.
    public init(_ type: URLRequest.NetworkServiceType) {
        self.type = type
    }

    public var body: some RequestBuildable {
        RequestState[\.request.networkServiceType, type]
    }
}
