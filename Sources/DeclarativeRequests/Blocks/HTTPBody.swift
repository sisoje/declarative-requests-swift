import Foundation

public enum HTTPBody {
    public static func json(_ value: any Encodable, encoder: JSONEncoder = .init()) -> RequestGroup {
        RequestGroup {
            CustomTransformer {
                $0.request.httpBody = try encoder.encode(value)
            }
            HTTPHeader.contentType.addValue("application/json")
        }
    }

    public static func data(_ data: Data?) -> CustomTransformer {
        CustomTransformer {
            $0.request.httpBody = data
        }
    }
}
