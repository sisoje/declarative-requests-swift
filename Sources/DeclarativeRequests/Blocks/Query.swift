import Foundation

public struct Query: RequestBuilderNode {
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

    let items: [URLQueryItem]

    public var body: some RequestBuilderRootNode {
        RootNode {
            let oldItems = $0.pathComponents.queryItems ?? []
            $0.pathComponents.queryItems = oldItems + items
        }
    }
}
