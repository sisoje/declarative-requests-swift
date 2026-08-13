import Foundation

extension Sequence where Element == RequestStateTransformClosure {
    var reduced: RequestStateTransformClosure {
        reduce({ _ in }) { partialResult, closure in
            {
                try partialResult($0)
                try closure($0)
            }
        }
    }
}

@_documentation(visibility: internal)
@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    @available(*, unavailable, message: "This type is not supported in request builder")
    static func buildExpression<Unsupported>(_: Unsupported) -> RequestBlock {
        fatalError()
    }

    static func buildBlock(_ components: any RequestBuildable...) -> RequestBlock {
        RequestBlock(components.map(\.transform).reduced)
    }

    static func buildExpression(_ component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    static func buildEither(first component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    static func buildEither(second component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }

    static func buildOptional(_ component: (any RequestBuildable)?) -> RequestBlock {
        RequestBlock(component?.transform ?? { _ in })
    }

    static func buildArray(_ components: [any RequestBuildable]) -> RequestBlock {
        RequestBlock(components.map(\.transform).reduced)
    }

    static func buildLimitedAvailability(_ component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }
}
