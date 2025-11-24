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
        self.items = items
    }

    public init(object: Any) {
        self.init(Dictionary(describingProperties: object))
    }

    let items: [URLQueryItem]

    public var body: some RequestBuildable {
        RequestTransformation { state in
            state.encodedBodyItems += items
            state.request.httpBody = state.encodedBodyItems.urlEncoded
        }
        ContentType.URLEncoded
    }
}
