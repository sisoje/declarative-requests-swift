protocol RequestBuilderNode {
    var transformer: RequestTransformer { get }
}

protocol RequestBuilderModifyNode: RequestBuilderNode {
    func modify(state: inout RequestBuilderState) throws
}

extension RequestBuilderModifyNode {
    var transformer: RequestTransformer { modify }
}
