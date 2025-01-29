import Foundation

public struct JSONBody: CompositeNode {
    public init(_ value: any Encodable, encoder: JSONEncoder = .init()) {
        self.value = value
        self.encoder = encoder
    }

    let value: any Encodable
    let encoder: JSONEncoder

    public var body: some BuilderNode {
        RootNode {
            RequestState[\.request.httpBody] { try encoder.encode(value) }
            Header.contentType.addValue("application/json")
        }
    }
}
