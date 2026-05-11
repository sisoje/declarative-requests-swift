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
        case .custom(let value): value
        }
    }

    func addValue(_ value: String) -> some RequestBuildable {
        RequestBlock {
            $0.request.addValue(value, forHTTPHeaderField: rawValue)
        }
    }

    func setValue(_ value: String) -> some RequestBuildable {
        RequestBlock {
            $0.request.setValue(value, forHTTPHeaderField: rawValue)
        }
    }
}
