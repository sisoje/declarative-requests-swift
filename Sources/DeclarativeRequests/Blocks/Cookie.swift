import Foundation

public struct Cookie: RequestBuildable {
    public init(_ name: String, _ value: String) {
        items = { _ in [URLQueryItem(name: name, value: value)] }
    }

    public init(_ encodable: any Encodable) {
        items = {
            try EncodableQueryItems(encodable: encodable, encoder: $0).items
        }
    }

    let items: (JSONEncoder) throws -> [URLQueryItem]

    public var body: some RequestBuildable {
        RequestStateTransformer { state in
            for item in try items(state.encoder) {
                state.cookies[item.name] = item.value ?? ""
            }
        }
    }
}
