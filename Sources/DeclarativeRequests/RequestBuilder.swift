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
    static func buildExpression<Unsupported>(_: Unsupported) -> RequestStateTransformer {
        fatalError()
    }

    static func buildBlock() -> RequestStateTransformer {
        RequestStateTransformer { _ in }
    }

    static func buildPartialBlock(first: any RequestBuildable) -> RequestStateTransformer {
        RequestStateTransformer(first.transform)
    }

    static func buildPartialBlock(accumulated: any RequestBuildable, next: any RequestBuildable) -> RequestStateTransformer {
        let lhs = accumulated.transform
        let rhs = next.transform
        return RequestStateTransformer { state in
            try lhs(state)
            try rhs(state)
        }
    }

    static func buildExpression(_ component: any RequestBuildable) -> RequestStateTransformer {
        RequestStateTransformer(component.transform)
    }

    static func buildEither(first component: any RequestBuildable) -> RequestStateTransformer {
        RequestStateTransformer(component.transform)
    }

    static func buildEither(second component: any RequestBuildable) -> RequestStateTransformer {
        RequestStateTransformer(component.transform)
    }

    static func buildOptional(_ component: (any RequestBuildable)?) -> RequestStateTransformer {
        RequestStateTransformer(component?.transform ?? { _ in })
    }

    static func buildArray(_ components: [any RequestBuildable]) -> RequestStateTransformer {
        RequestStateTransformer(components.map(\.transform).reduced)
    }

    static func buildLimitedAvailability(_ component: any RequestBuildable) -> RequestStateTransformer {
        RequestStateTransformer(component.transform)
    }
}
