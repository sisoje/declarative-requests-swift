import Foundation

public enum Header {
    case contentType
    case accept
    case authorization
    case userAgent
    case origin
    case cookie
    case referer
    case acceptLanguage
    case acceptEncoding
    case cacheControl
    case ifNoneMatch
    case range
    case custom(String)

    public var rawValue: String {
        switch self {
        case .contentType: "Content-Type"
        case .accept: "Accept"
        case .authorization: "Authorization"
        case .userAgent: "User-Agent"
        case .origin: "Origin"
        case .cookie: "Cookie"
        case .referer: "Referer"
        case .acceptLanguage: "Accept-Language"
        case .acceptEncoding: "Accept-Encoding"
        case .cacheControl: "Cache-Control"
        case .ifNoneMatch: "If-None-Match"
        case .range: "Range"
        case let .custom(name): name
        }
    }

    public func addValue(_ value: String) -> some RequestBuildable {
        RequestBlock { state in
            state.request.addValue(value, forHTTPHeaderField: rawValue)
        }
    }

    public func setValue(_ value: String) -> some RequestBuildable {
        RequestBlock { state in
            state.request.setValue(value, forHTTPHeaderField: rawValue)
        }
    }
}
