import Foundation

public enum Header: String {
    case contentType = "Content-Type"
    case accept = "Accept"
    case authorization = "Authorization"
    case userAgent = "User-Agent"
    case origin = "Origin"
    case referer = "Referer"
    case acceptLanguage = "Accept-Language"
    case acceptEncoding = "Accept-Encoding"
}

public extension Header {
    func addValue(_ value: String) -> some BuilderNode {
        RequestBlock {
            $0.request.addValue(value, forHTTPHeaderField: rawValue)
        }
    }

    static func addCustom(header: String, value: String) -> some BuilderNode {
        RequestBlock {
            $0.request.addValue(value, forHTTPHeaderField: header)
        }
    }
}
