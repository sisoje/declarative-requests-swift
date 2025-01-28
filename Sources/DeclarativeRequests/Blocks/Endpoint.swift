struct Endpoint: RequestBuilderNode {
    let path: String
    func modify(state: inout RequestBuilderState) {
        state.pathComponents.path = path
    }
}

extension RequestBuilder {
    static func buildExpression(_ str: String) -> RequestTransformer {
        Endpoint(path: str).transformer
    }
}
