import Foundation

public struct DataBody: CompositeNode {
    public init(_ value: Data) {
        self.value = value
    }

    let value: Data

    public var body: some BuilderNode {
        RequestState[\.request.httpBody] { value }
        Header.contentType.addValue("application/octet-stream")
    }
}
