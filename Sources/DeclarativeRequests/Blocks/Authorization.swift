import Foundation

public enum Authorization {
    public static func custom(value: () -> String) -> some BuilderNode {
        Header.authorization.setValue(value())
    }

    public static func bearer(_ data: Data) -> some BuilderNode {
        bearer(data.base64EncodedString())
    }

    public static func bearer(_ string: String) -> some BuilderNode {
        custom { "Bearer \(string)" }
    }

    public static func basic(username: String, password: String) -> some BuilderNode {
        custom {
            let credentials = "\(username):\(password)"
            let data = Data(credentials.utf8)
            let base64 = data.base64EncodedString()
            return "Basic \(base64)"
        }
    }
}
