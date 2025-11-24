import Foundation

extension [URLQueryItem] {
    var urlEncoded: Data? {
        var components = URLComponents()
        components.queryItems = self
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    static func from(_ encodable: Encodable, encoder: JSONEncoder) throws -> [URLQueryItem] {
        let data = try encoder.encode(encodable)
        let json = try JSONSerialization.jsonObject(with: data)
        return from(json, name: "")
    }

    private static func from(_ any: Any, name: String) -> [URLQueryItem] {
        if let dict = any as? [String: Any] {
            dict.flatMap { key, value in
                from(value, name: key)
            }
        } else if let arr = any as? [Any] {
            arr.enumerated().flatMap { index, item in
                from(item, name: "\(name)[\(index)]")
            }
        } else {
            [URLQueryItem(name: name, value: String(describing: any))]
        }
    }
}
