protocol RequestBuilderNode {
    func modify(state: inout RequestBuilderState) throws
    var transformer: RequestTransformer { get }
}

extension RequestBuilderNode {
    var transformer: RequestTransformer { modify }
    func modify(state: inout RequestBuilderState) throws {
        try transformer(&state)
    }
}
