import Foundation

@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    typealias Expression = BuilderNode

    typealias Component = RequestBlock

    typealias Result = RequestBlock

    @available(*, unavailable, message: "This type is not supported in request builder")
    static func buildExpression<Unsupported>(_ value: Unsupported) -> RequestBlock {
        fatalError()
    }

    /// Build empty block
    static func buildBlock() -> RequestBlock {
        RequestBlock()
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: BuilderNode...) -> RequestBlock {
        RequestBlock(components.map(\.transformer))
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ component: BuilderNode) -> RequestBlock {
        RequestBlock(component.transformer)
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: BuilderNode) -> RequestBlock {
        RequestBlock(component.transformer)
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: BuilderNode) -> RequestBlock {
        RequestBlock(component.transformer)
    }

    /// Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: BuilderNode?) -> RequestBlock {
        RequestBlock(component?.transformer ?? { _ in })
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [BuilderNode]) -> RequestBlock {
        RequestBlock(components.map(\.transformer))
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: BuilderNode) -> RequestBlock {
        RequestBlock(component.transformer)
    }
}
