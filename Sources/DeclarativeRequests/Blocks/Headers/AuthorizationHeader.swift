import Foundation

public enum AuthorizationHeader {
    public static func raw(_ value: String) -> some HeaderBuildable {
        Header.authorization.setValue(value)
    }

    public static func bearer(_ token: String) -> some HeaderBuildable {
        Header.authorization.setValue("Bearer \(token)")
    }

    public static func token(_ token: String) -> some HeaderBuildable {
        Header.authorization.setValue("Token \(token)")
    }

    public static func basic(username: String, password: String) -> some HeaderBuildable {
        let encoded = Data("\(username):\(password)".utf8).base64EncodedString()
        return Header.authorization.setValue("Basic \(encoded)")
    }

    public static func scheme(_ scheme: String, value: String) -> some HeaderBuildable {
        Header.authorization.setValue("\(scheme) \(value)")
    }
}
