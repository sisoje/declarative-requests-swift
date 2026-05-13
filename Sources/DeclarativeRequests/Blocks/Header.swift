import Foundation

public enum Header: Equatable, Hashable {
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
}

public extension Header {
    var rawValue: String {
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
        case let .custom(value): value
        }
    }

    func value(_ string: String) -> some HeaderBuildable {
        CustomHeader(rawValue, string)
    }

    func addValue(_ string: String) -> some HeaderBuildable {
        value(string).headersAdd()
    }

    func setValue(_ string: String) -> some HeaderBuildable {
        value(string).headersSet()
    }
}
