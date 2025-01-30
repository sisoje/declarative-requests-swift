import Foundation

public enum ContentType: String, CompositeNode {
    case URLEncoded = "application/x-www-form-urlencoded"
    case JSON = "application/json"

    public var body: some BuilderNode {
        Header.contentType.setValue(rawValue)
    }
}
