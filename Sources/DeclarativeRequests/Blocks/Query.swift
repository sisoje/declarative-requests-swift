import Foundation

public struct Query: RequestBuildable {
    public init(_ name: String, _ value: String?) {
        items = { _ in [URLQueryItem(name: name, value: value)] }
    }

    public init(_ encodable: any Encodable) {
        items = {
            try EncodableQueryItems(encodable: encodable, encoder: $0).items
        }
    }

    let items: (JSONEncoder) throws -> [URLQueryItem]

    public var body: some RequestBuildable {
        RequestTransformation { state in
            state.queryItems += try items(state.encoder)
        }
    }
}
