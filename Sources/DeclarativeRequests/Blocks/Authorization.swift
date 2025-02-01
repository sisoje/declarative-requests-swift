import Foundation

public enum Authorization: CompositeNode {
    case basic(username: String, password: String?)
    case bearer(token: String?)
    case custom(String?)
    
    public var body: some BuilderNode {
        RequestBlock {
            switch self {
            case .basic(let username, let password):
                if let password = password,
                   let authString = basic(username: username, password: password) {
                    Header.authorization.setValue(authString)
                }
                
            case .bearer(let token):
                if let token = token {
                    Header.authorization.setValue("Bearer \(token)")
                }
                
            case .custom(let value):
                if let value = value {
                    Header.authorization.setValue(value)
                }
            }
        }
    }
    
    private func basic(username: String, password: String) -> String? {
        let credentials = "\(username):\(password)"
        guard let data = credentials.data(using: .utf8) else {
            return nil
        }
        let base64 = data.base64EncodedString()
        return "Basic \(base64)"
    }
}