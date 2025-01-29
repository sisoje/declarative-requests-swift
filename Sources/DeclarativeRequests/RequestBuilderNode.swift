import Foundation

public protocol RequestBuilderNode: RequestBuilderRootNode {
    associatedtype ChildNode: RequestBuilderRootNode
    var body: ChildNode { get }
}

public extension RequestBuilderNode {
    var transformer: StateTransformer { body.transformer }
}
