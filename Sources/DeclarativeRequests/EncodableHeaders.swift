import Foundation

/// Encodes a model into a flat list of HTTP header (name, value) pairs.
/// Throws if the encoded payload isn't a flat JSON object — headers cannot carry
/// nested arrays or dictionaries.
struct EncodableHeaders {
    let encodable: any Encodable
    let encoder: JSONEncoder

    var pairs: [(name: String, value: String)] {
        get throws {
            let data = try encoder.encode(encodable)
            let json = try JSONSerialization.jsonObject(with: data)
            guard let dict = json as? [String: Any] else {
                throw DeclarativeRequestsError.encodingFailed(
                    reason: "Headers model must encode to a JSON object"
                )
            }
            return try dict
                .sorted { $0.key < $1.key }
                .compactMap { entry in
                    if entry.value is NSNull { return nil }
                    if entry.value is [Any] || entry.value is [String: Any] {
                        throw DeclarativeRequestsError.encodingFailed(
                            reason: "Header '\(entry.key)' has nested value; headers must be flat"
                        )
                    }
                    return (name: entry.key, value: Self.stringValue(of: entry.value))
                }
        }
    }

    private static func stringValue(of any: Any) -> String {
        if let str = any as? String { return str }
        if let bool = any as? Bool { return String(describing: bool) }
        return String(describing: any)
    }
}
