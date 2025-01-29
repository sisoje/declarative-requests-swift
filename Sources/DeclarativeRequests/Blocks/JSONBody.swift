import Foundation

public struct JSONBody: RequestBuilderModifyNode {
    public init(_ value: any Encodable, encoder: JSONEncoder = .init()) {
        self.value = value
        self.encoder = encoder
    }
    
    let value: any Encodable
    let encoder: JSONEncoder
    
    var body: some RequestBuilderNode {
        RequestGroup {
            RequestBuilderState[\.request.httpBody] { try encoder.encode(value) }
            HTTPHeader.contentType.addValue("application/json")
        }
    }
}
