import Foundation

public struct Query: RequestBuildable {
    public init(_ items: [URLQueryItem]) {
        self.items = { _ in items }
    }

    public init(_ name: String, _ value: String?) {
        self.init([name: value])
    }

    public init(_ params: [(String, String?)]) {
        self.init(params.map(URLQueryItem.init))
    }

    public init(_ params: [String: String?]) {
        self.init(Array(params))
    }

    public init<T: Encodable>(_ encodable: T) {
        items = {
            try EncodableQueryItems(encodable, encoder: $0).items
        }
    }

    let items: (JSONEncoder) throws -> [URLQueryItem]

    public var body: some RequestBuildable {
        RequestTransformation { state in
            let oldItems = state.pathComponents.queryItems ?? []
            let newItems = try items(state.encoder)
            state.pathComponents.queryItems = (oldItems + newItems).sorted { $0.name < $1.name }
        }
    }
}

struct AnyQueryItems {
    let name: String
    let any: Any

    var items: [URLQueryItem] {
        if let dict = any as? [String: Any] {
            Array(dict).flatMap { key, value in
                AnyQueryItems(name: key, any: value).items
            }
        } else if let arr = any as? [Any] {
            arr.enumerated().flatMap { index, item in
                AnyQueryItems(name: "\(name)[\(index)]", any: item).items
            }
        } else {
            [URLQueryItem(name: name, value: String(describing: any))]
        }
    }
}

struct EncodableQueryItems<T: Encodable> {
    init(_ encodable: T, encoder: JSONEncoder) {
        self.encodable = encodable
        self.encoder = encoder
    }

    let encodable: T
    let encoder: JSONEncoder

    var items: [URLQueryItem] {
        get throws {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data)
            return try AnyQueryItems(name: "", any: json).items
        }
    }
}
