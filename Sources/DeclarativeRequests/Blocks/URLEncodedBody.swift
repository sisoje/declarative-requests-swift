import Foundation

public struct URLEncodedBody: RequestBuildable {
    public init(_ name: String, _ value: String?) {
        self.init([name: value])
    }

    public init(_ params: [(String, String?)]) {
        self.init(params.map(URLQueryItem.init))
    }

    public init(_ params: [String: String?]) {
        self.init(Array(params))
    }

    public init(_ items: [URLQueryItem]) {
        self.items = { _ in items }
    }

    public init<T: Encodable>(_ encodable: T) {
        items = {
            try EncodableQueryItems(encodable, encoder: $0).items
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
