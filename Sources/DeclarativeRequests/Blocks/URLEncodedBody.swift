import Foundation

public struct URLEncodedBody: RequestBuildable {
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
            let newItems = try items(state.encoder)
            state.encodedBodyItems += newItems
            state.request.httpBody = state.encodedBodyItems.urlEncoded
        }
        ContentType.URLEncoded
    }
}
