import Foundation

public struct MIMEType: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MIMEType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        rawValue = value
    }
}

public extension MIMEType {
    static let json: MIMEType = "application/json"
    static let xml: MIMEType = "application/xml"
    static let html: MIMEType = "text/html"
    static let plainText: MIMEType = "text/plain"
    static let formURLEncoded: MIMEType = "application/x-www-form-urlencoded"
    static let octetStream: MIMEType = "application/octet-stream"
    static let png: MIMEType = "image/png"
    static let jpeg: MIMEType = "image/jpeg"
}
