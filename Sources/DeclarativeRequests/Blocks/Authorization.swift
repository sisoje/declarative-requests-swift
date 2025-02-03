import Foundation

public struct Authorization: CompositeNode {
    public init(username: String, password: String) {
        let credentials = "\(username):\(password)"
        let data = Data(credentials.utf8)
        let base64 = data.base64EncodedString()
        value = "Basic \(base64)"
    }

    public init(bearer token: String) {
        value = "Bearer \(token)"
    }

    public init(_ value: String) {
        self.value = value
    }

    let value: String

    public var body: some BuilderNode {
        Header.authorization.setValue(value)
    }
}
