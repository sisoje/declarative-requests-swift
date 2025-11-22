import Foundation

public struct Query: CompositeNode {
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
    
    public init(enumValue: Any) {
        self.init(Dictionary(describingPropertiesEnum: enumValue))
    }

    let items: [URLQueryItem]

    public var body: some BuilderNode {
        RequestBlock {
            let oldItems = $0.pathComponents.queryItems ?? []
            $0.pathComponents.queryItems = (oldItems + items).sorted { $0.name < $1.name }
        }
    }
}
