import Foundation

public struct JSONBody<T: Encodable>: RequestBuilderModifyNode {
    let value: T
    var encoder = JSONEncoder()
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = try encoder.encode(value)
        state.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
