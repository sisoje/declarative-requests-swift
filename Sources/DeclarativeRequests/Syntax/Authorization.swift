import Foundation

/// `Authorization: <scheme> <credentials>` — the auth-scheme token of RFC 9110 §11.6.2.
public enum Authorization: Sendable {
    case bearer
    case digest
    case negotiate

    public var rawValue: String {
        switch self {
        case .bearer: "Bearer"
        case .digest: "Digest"
        case .negotiate: "Negotiate"
        }
    }

    /// Sets the header to this scheme followed by the credentials, verbatim.
    public func callAsFunction(_ credentials: String) -> some RequestBuildable {
        Header.authorization.setValue("\(rawValue) \(credentials)")
    }

    /// Any other scheme, in wire order — `Authorization: <scheme> <credentials>`.
    public static func custom(_ scheme: String, _ credentials: String) -> some RequestBuildable {
        Header.authorization.setValue("\(scheme) \(credentials)")
    }

    /// Basic is the one scheme whose credentials the package encodes — RFC 7617, Base64 of
    /// `username:password` in UTF-8. Pre-encoded credentials go through `.custom("Basic", …)`.
    public static func basic(username: String, password: String) -> some RequestBuildable {
        Header.authorization.setValue("Basic \(Data("\(username):\(password)".utf8).base64EncodedString())")
    }
}
