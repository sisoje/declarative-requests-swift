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
    func addValue(_ value: String) -> some RequestBuilderNode {
        Self.addCustom(header: rawValue, value: value)
    }

    static func addCustom(header: String, value: String) -> some RequestBuilderNode {
        RootNode {
            $0.request.addValue(value, forHTTPHeaderField: header)
        }
    }
}
