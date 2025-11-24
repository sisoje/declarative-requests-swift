import Foundation

public struct URLEncodedBody: RequestBuildable {
    public init(_ name: String, _ value: String?) {
        items = { _ in [URLQueryItem(name: name, value: value)] }
    }

    public init<T: Encodable>(_ encodable: T) {
        items = {
            try [URLQueryItem].from(encodable, encoder: $0)
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
