import SwiftUI

struct AnyQuery: CompositeNode {
    let name: String
    let any: Any

    var body: some BuilderNode {
        if let dict = any as? [String: Any] {
            for (key, value) in dict {
                AnyQuery(name: key, any: value)
            }
        } else if let arr = any as? [Any] {
            for i in 0 ..< arr.count {
                AnyQuery(name: "\(name)[\(i)]", any: arr[i])
            }
        } else {
            Query(name, String(describing: any))
        }
    }
}

public struct EncodableQuery<T: Encodable>: CompositeNode {
    public init(name: String = "", _ encodable: T, encoder: JSONEncoder = .init()) {
        self.name = name
        self.encodable = encodable
        self.encoder = encoder
    }

    let name: String
    let encodable: T
    let encoder: JSONEncoder

    var json: Any {
        get throws {
            let data = try encoder.encode(encodable)
            do {
                return try JSONSerialization.jsonObject(with: data)
            } catch {
                return String(decoding: data, as: UTF8.self)
            }
        }
    }

    public var body: some BuilderNode {
        RequestBlock { state in
            try AnyQuery(name: name, any: json).transformer(&state)
        }
    }
}
