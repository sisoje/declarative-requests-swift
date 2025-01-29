import Foundation

public protocol RequestBuilderCompositeNode: RequestBuilderNode {
    associatedtype ChildNode: RequestBuilderNode
    var body: ChildNode { get }
}

public extension RequestBuilderCompositeNode {
    var transformer: StateTransformer { body.transformer }
}
