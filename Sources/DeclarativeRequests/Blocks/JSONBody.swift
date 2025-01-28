import Foundation

public struct JSONBody<T: Encodable>: RequestBuilderModifyNode {
    public init(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self.value = value
        self.encoder = encoder
    }
    
    let value: T
    let encoder: JSONEncoder
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = try encoder.encode(value)
        state.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
