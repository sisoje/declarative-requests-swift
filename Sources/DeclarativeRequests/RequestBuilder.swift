import Foundation

@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    static func buildBlock() -> some BuilderNode {
        RootNode()
    }

    static func buildBlock(_ components: BuilderNode...) -> some BuilderNode {
        RootNode(components.map(\.transformer))
    }

//
//    static func buildBlock(_ components: RequestBuilderNode...) -> RequestTransformer {
//        components.map(\.transformer).reduced
//    }
//
//    /// Required by every result builder to build combined results from statement blocks
//    static func buildBlock(_ components: RequestTransformer...) -> RequestTransformer {
//        components.reduced
//    }
//
//    /// If declared, provides contextual type information for statement expressions to translate them into partial results
//    static func buildExpression(_ expression: RequestBuilderNode) -> RequestBuilderNode {
//        expression
//    }
//
//    static func buildExpression(_ expression: () -> RequestTransformer) -> RequestTransformer {
//        expression()
//    }
//
//    /// Required by every result builder to build combined results from statement blocks
//    static func buildBlock(_ components: [RequestBuilderNode]...) -> RequestTransformer {
//        components.flatMap { $0 }.map(\.transformer).reduced
//    }
//
    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: BuilderNode) -> BuilderNode {
        component
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: BuilderNode) -> BuilderNode {
        component
    }

    // Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: BuilderNode?) -> BuilderNode {
        component ?? RootNode()
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [BuilderNode]) -> BuilderNode {
        RootNode(components.map(\.transformer))
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: BuilderNode) -> BuilderNode {
        component
    }

//    /// Builds a partial result component from the first component
//    static func buildPartialBlock(first: @escaping RequestTransformer) -> RequestTransformer {
//        first
//    }
//
//    /// Builds a partial result component by combining an accumulated component and a new component
//    static func buildPartialBlock(accumulated: @escaping RequestTransformer, next: @escaping RequestTransformer) -> RequestTransformer {
//        RequestTransformerUtils.merge(accumulated, next)
//    }
//
//    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result
//    static func buildFinalResult(_ component: @escaping RequestTransformer) -> RequestTransformer {
//        component
//    }
}
