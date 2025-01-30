import Foundation

public struct Query: CompositeNode {
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
        self.items = Array(queryItemsReflecting: object)
    }

    let items: [URLQueryItem]

    public var body: some BuilderNode {
        RequestBlock {
            let oldItems = $0.pathComponents.queryItems ?? []
            $0.pathComponents.queryItems = oldItems + items
        }
    }
}
