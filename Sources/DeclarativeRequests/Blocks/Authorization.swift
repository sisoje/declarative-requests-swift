import Foundation

public struct Authorization: RequestBuildable {
    public init(username: String, password: String) {
        let credentials = "\(username):\(password)"
        let data = Data(credentials.utf8)
        let base64 = data.base64EncodedString()
        value = "Basic \(base64)"
    }

    public init(bearer token: String) {
        value = "Bearer \(token)"
    }

    let value: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request.setValue(value, forHTTPHeaderField: Header.authorization.rawValue)
        }
    }
}
