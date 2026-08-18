import Foundation

/// Adds query items. Values follow `URLComponents` encoding — a literal `+` stays `+`; percent-encode it yourself if your server decodes `+` as space.
public struct Query: RequestBuildable {
    enum Source {
        case pair(name: String, value: String?)
        case encodable(any Encodable & Sendable)
    }

    /// A `nil` value renders a bare key (`?flag`) — wrap in `if let` to omit the item. Non-lossless values convert explicitly (`uuid.uuidString`).
    public init(_ name: String, _ value: (some LosslessStringConvertible)?) {
        source = .pair(name: name, value: value?.description)
    }

    public init(_ encodable: any Encodable & Sendable) {
        source = .encodable(encodable)
    }

    let source: Source

    public var body: some RequestBuildable {
        RequestBlock { state in
            switch source {
            case let .pair(name, value):
                state.queryItems += [URLQueryItem(name: name, value: value)]
            case let .encodable(encodable):
                state.queryItems += try EncodableQueryItems(encodable: encodable, encoder: state.encoder).items
            }
        }
    }
}
