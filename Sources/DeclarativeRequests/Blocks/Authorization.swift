import Foundation

public enum Authorization {}

public extension Authorization {
    static func bearer(_ token: String) -> some RequestBuildable {
        Header.authorization.setValue("Bearer \(token)")
    }

    static func basic(username: String, password: String) -> some RequestBuildable {
        let base64 = Data("\(username):\(password)".utf8).base64EncodedString()
        return Header.authorization.setValue("Basic \(base64)")
    }

    static func token(_ token: String) -> some RequestBuildable {
        Header.authorization.setValue("Token \(token)")
    }

    static func other(_ scheme: String, credentials: String) -> some RequestBuildable {
        Header.authorization.setValue("\(scheme) \(credentials)")
    }

    static func raw(_ value: String) -> some RequestBuildable {
        Header.authorization.setValue(value)
    }

    static func custom(_ authenticator: @escaping (inout URLRequest) throws -> Void) -> some RequestBuildable {
        RequestBlock { state in
            try authenticator(&state.request)
        }
    }
}
