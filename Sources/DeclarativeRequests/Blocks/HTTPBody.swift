import Foundation

public enum HTTPBody {
    public static func json(_ value: any Encodable, encoder: JSONEncoder = .init()) -> CustomTransformer {
        CustomTransformer {
            $0.request.httpBody = try encoder.encode(value)
            $0.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    public static func data(_ data: Data?) -> CustomTransformer {
        CustomTransformer {
            $0.request.httpBody = data
            $0.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
