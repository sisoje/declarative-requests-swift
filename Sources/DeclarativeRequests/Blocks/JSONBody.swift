import Foundation

public struct JSONBody: CompositeNode {
    public init(_ value: any Encodable, encoder: JSONEncoder = .init()) {
        dataSource = { try encoder.encode(value) }
    }

    let dataSource: () throws -> Data

    public var body: some BuilderNode {
        RequestState[\.request.httpBody, dataSource]
        ContentType.JSON
    }
}
