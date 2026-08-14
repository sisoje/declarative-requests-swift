import Foundation

public struct Query: RequestBuildable {
    enum Source {
        case pair(name: String, value: String?)
        case encodable(any Encodable)
    }

    public init(_ name: String, _ value: String?) {
        source = .pair(name: name, value: value)
    }

    public init(_ encodable: any Encodable) {
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
