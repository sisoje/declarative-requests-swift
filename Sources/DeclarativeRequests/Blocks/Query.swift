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

    public init(_ value: some Encodable) {
        let data = try? JSONEncoder().encode(value)
        guard let dict = try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String: Any],
              dict.values.allSatisfy({ $0 is String || $0 is NSNumber }) else {
            self.items = []
            return
        }
        self.items = dict.map { URLQueryItem(name: $0, value: String(describing: $1)) }
    }

    let items: [URLQueryItem]

    public var body: some BuilderNode {
        RootNode {
            let oldItems = $0.pathComponents.queryItems ?? []
            $0.pathComponents.queryItems = oldItems + items
        }
    }
}
