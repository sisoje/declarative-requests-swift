import Foundation

public struct DataBody: CompositeNode {
    public init(_ data: Data? = nil) {
        self.data = data
    }

    let data: Data?

    public var body: some BuilderNode {
        RequestState[\.request.httpBody, data]
    }
}
