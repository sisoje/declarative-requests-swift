import Foundation

public struct AuthorizationHeaderValue: SingleValueHeader {
    public static var headerName: Header { .authorization }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }
}

public enum AuthorizationHeader {
    public static func raw(_ value: String) -> AuthorizationHeaderValue {
        AuthorizationHeaderValue(value: value)
    }

    public static func bearer(_ token: String) -> AuthorizationHeaderValue {
        AuthorizationHeaderValue(value: "Bearer \(token)")
    }

    public static func token(_ token: String) -> AuthorizationHeaderValue {
        AuthorizationHeaderValue(value: "Token \(token)")
    }

    public static func basic(username: String, password: String) -> AuthorizationHeaderValue {
        let encoded = Data("\(username):\(password)".utf8).base64EncodedString()
        return AuthorizationHeaderValue(value: "Basic \(encoded)")
    }

    public static func scheme(_ scheme: String, value: String) -> AuthorizationHeaderValue {
        AuthorizationHeaderValue(value: "\(scheme) \(value)")
    }
}
