import Foundation

public enum HTTPBody {
    public static func json(_ value: any Encodable, encoder: JSONEncoder = .init()) -> RequestGroup {
        RequestGroup {
            RequestBuilderState[\.request.httpBody] { try encoder.encode(value) }
            HTTPHeader.contentType.addValue("application/json")
        }
    }

    public static func data(_ data: Data?) -> CustomTransformer {
        RequestBuilderState[\.request.httpBody, data]
    }
}
