import Foundation

public enum Header {
    case contentType
    case accept
    case authorization
    case userAgent
    case origin
    case cookie
    case referer
    case host
    case acceptLanguage
    case acceptEncoding
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
        case .host: "Host"
        case .acceptLanguage: "Accept-Language"
        case .acceptEncoding: "Accept-Encoding"
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
