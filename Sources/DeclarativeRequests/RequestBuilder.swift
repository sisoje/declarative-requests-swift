import Foundation

@resultBuilder
struct RequestBuilder {
    static func buildBlock() -> RequestTransformer {
        RequestTransformerUtils.nop
    }

    static func buildBlock(_ components: () -> RequestTransformer...) -> RequestTransformer {
        components.map { $0() }.reduced
    }

    static func buildBlock(_ components: RequestBuilderNode...) -> RequestTransformer {
        components.map(\.transformer).reduced
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: RequestTransformer...) -> RequestTransformer {
        components.reduced
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ expression: RequestBuilderNode) -> RequestTransformer {
        expression.transformer
    }

    static func buildExpression(_ expression: () -> RequestTransformer) -> RequestTransformer {
        expression()
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: [RequestBuilderNode]...) -> RequestTransformer {
        components.flatMap { $0 }.map(\.transformer).reduced
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    // Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: RequestTransformer?) -> RequestTransformer {
        component ?? RequestTransformerUtils.nop
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [RequestTransformer]) -> RequestTransformer {
        components.reduced
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }

    /// Builds a partial result component from the first component
    static func buildPartialBlock(first: @escaping RequestTransformer) -> RequestTransformer {
        first
    }

    /// Builds a partial result component by combining an accumulated component and a new component
    static func buildPartialBlock(accumulated: @escaping RequestTransformer, next: @escaping RequestTransformer) -> RequestTransformer {
        RequestTransformerUtils.merge(accumulated, next)
    }

    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result
    static func buildFinalResult(_ component: @escaping RequestTransformer) -> RequestTransformer {
        component
    }
}
