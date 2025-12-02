import Foundation

@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    static func buildExpression(_ url: URL) -> RequestTransformation {
        RequestTransformation {
            $0.setBaseURL(url)
        }
    }

    static func buildExpression(_ stream: InputStream?) -> RequestTransformation {
        RequestState[\.request.httpBodyStream, stream]
    }

    @available(*, unavailable, message: "This type is not supported in request builder")
    static func buildExpression<Unsupported>(_: Unsupported) -> RequestTransformation {
        fatalError()
    }

    /// Build empty block
    static func buildBlock() -> RequestTransformation {
        RequestTransformation()
    }

    /// Required by every result builder to build combined results from statement blocks
    static func buildBlock(_ components: any RequestBuildable...) -> RequestTransformation {
        RequestTransformation(components.map(\.transform))
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results
    static func buildExpression(_ component: any RequestBuildable) -> RequestTransformation {
        RequestTransformation(component.transform)
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(first component: any RequestBuildable) -> RequestTransformation {
        RequestTransformation(component.transform)
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result
    static func buildEither(second component: any RequestBuildable) -> RequestTransformation {
        RequestTransformation(component.transform)
    }

    /// Enables support for 'if' statements that do not have an 'else'
    static func buildOptional(_ component: (any RequestBuildable)?) -> RequestTransformation {
        RequestTransformation(component?.transform ?? { _ in })
    }

    /// Enables support for...in loops in a result builder by combining the results of all iterations into a single result
    static func buildArray(_ components: [any RequestBuildable]) -> RequestTransformation {
        RequestTransformation(components.map(\.transform))
    }

    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information
    static func buildLimitedAvailability(_ component: any RequestBuildable) -> RequestTransformation {
        RequestTransformation(component.transform)
    }
}
