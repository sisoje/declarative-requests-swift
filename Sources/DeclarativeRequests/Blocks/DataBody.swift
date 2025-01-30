import Foundation

public struct DataBody: CompositeNode {
    public init(_ data: Data) {
        self.data = data
    }

    public init(_ string: String) {
        data = string.data(using: .utf8)
    }

    let data: Data?

    public var body: some BuilderNode {
        RequestState[\.request.httpBody, data]
    }
}
