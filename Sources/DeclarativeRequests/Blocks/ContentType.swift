import Foundation

public enum ContentType: String, CompositeNode {
    case URLEncoded = "application/x-www-form-urlencoded"
    case JSON = "application/json"
    case Stream = "application/octet-stream"

    public var body: some BuilderNode {
        Header.contentType.setValue(rawValue)
    }
}
