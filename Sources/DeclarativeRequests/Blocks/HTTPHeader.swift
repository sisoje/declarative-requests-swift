import Foundation

public enum HTTPHeader: String {
    case contentType = "Content-Type"
    case accept = "Accept"
    case authorization = "Authorization"
    case userAgent = "User-Agent"
    case origin = "Origin"
    case referer = "Referer"
    case acceptLanguage = "Accept-Language"
    case acceptEncoding = "Accept-Encoding"
}

public extension HTTPHeader {
    func addValue(_ value: String) -> CustomTransformer {
        CustomTransformer {
            $0.request.addValue(value, forHTTPHeaderField: rawValue)
        }
    }

    static func addCustom(header: String, value: String) -> CustomTransformer {
        CustomTransformer {
            $0.request.addValue(value, forHTTPHeaderField: header)
        }
    }
}
