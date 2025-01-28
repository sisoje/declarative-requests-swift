import Foundation

public struct HTTPBody: RequestBuilderModifyNode {
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = data
    }

    let data: Data?

    public init(_ data: Data?) {
        self.data = data
    }
}
