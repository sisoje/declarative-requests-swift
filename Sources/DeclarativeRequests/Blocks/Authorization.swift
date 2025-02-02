import Foundation

public enum Authorization {
    public static func custom(value: () -> String) -> some BuilderNode {
        Header.authorization.setValue(value())
    }

    public static func bearer(_ data: Data) -> some BuilderNode {
        custom {
            let base64 = data.base64EncodedString()
            return "Bearer \(base64)"
        }
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
