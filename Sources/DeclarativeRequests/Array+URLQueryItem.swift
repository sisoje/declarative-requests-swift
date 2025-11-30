import Foundation

struct AnyQueryItems {
    let name: String
    let any: Any

    var stringValue: String {
        if let string = any as? String {
            string
        } else if let bool = any as? Bool {
            String(describing: bool)
        } else {
            String(describing: any)
        }
    }

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
            [URLQueryItem(name: name, value: stringValue)]
        }
    }
}

struct EncodableQueryItems {
    let encodable: any Encodable
    let encoder: JSONEncoder

    var items: [URLQueryItem] {
        get throws {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data)
            return AnyQueryItems(name: "", any: json).items
        }
    }
}

extension [URLQueryItem] {
    var urlEncoded: Data? {
        var components = URLComponents()
        components.queryItems = self
        return components.percentEncodedQuery?.data(using: .utf8)
    }
}
