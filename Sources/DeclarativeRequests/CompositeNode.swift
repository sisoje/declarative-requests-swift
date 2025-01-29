import Foundation

public protocol CompositeNode: BuilderNode {
    associatedtype ChildNode: BuilderNode
    var body: ChildNode { get }
}

public extension CompositeNode {
    var transformer: StateTransformer { body.transformer }
}
