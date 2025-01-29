public protocol RequestBuilderNode {
    var transformer: RequestTransformer { get }
}

public protocol RequestBuilderModifyNode: RequestBuilderNode {
    associatedtype ChildNode: RequestBuilderNode
    var body: ChildNode { get }
}

public extension RequestBuilderModifyNode {
    var transformer: RequestTransformer { body.transformer }
}
