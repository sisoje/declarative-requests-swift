import Foundation

@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    /// Build empty block
    static func buildBlock() -> RootNode {
        RootNode()
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: BuilderNode...) -> RootNode {
        RootNode(components.map(\.transformer))
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ component: BuilderNode) -> RootNode {
        RootNode(component.transformer)
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: BuilderNode) -> RootNode {
        RootNode(component.transformer)
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: BuilderNode) -> RootNode {
        RootNode(component.transformer)
    }

    /// Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: BuilderNode?) -> RootNode {
        RootNode(component?.transformer ?? { _ in })
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [BuilderNode]) -> RootNode {
        RootNode(components.map(\.transformer))
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: BuilderNode) -> RootNode {
        RootNode(component.transformer)
    }
}

