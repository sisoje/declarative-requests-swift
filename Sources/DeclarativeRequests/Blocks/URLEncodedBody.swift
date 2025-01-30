import Foundation

public struct URLEncodedBody: CompositeNode {
    public init(_ name: String, _ value: String?) {
        items = [URLQueryItem(name: name, value: value)]
    }

    public init(_ params: [(String, String?)]) {
        items = params.map(URLQueryItem.init)
    }

    public init(_ params: [String: String?]) {
        items = params.map(URLQueryItem.init)
    }

    public init(_ items: [URLQueryItem]) {
        self.items = items
    }

    public init(object: Any) {
        items = Array(queryItemsReflecting: object)
    }

    let items: [URLQueryItem]

    public var body: some BuilderNode {
        RequestBlock { state in
            state.encodedBodyItems += items
            state.request.httpBody = .httpBody(state.encodedBodyItems)
        }
    }
}
