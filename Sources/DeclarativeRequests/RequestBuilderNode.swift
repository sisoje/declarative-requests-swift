protocol RequestBuilderNode {
    var transformer: RequestTransformer { get }
}

protocol RequestBuilderModifyNode: RequestBuilderNode {
    associatedtype ChildNode: RequestBuilderNode
    var body: ChildNode { get }
}

extension RequestBuilderModifyNode {
    var transformer: RequestTransformer { body.transformer }
}
