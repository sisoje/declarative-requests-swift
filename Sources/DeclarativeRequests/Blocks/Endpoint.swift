public struct Endpoint: RequestBuilderModifyNode {
    public init(_ path: String) {
        self.path = path
    }

    let path: String
    func modify(state: inout RequestBuilderState) {
        state.pathComponents.path = path
    }
}
