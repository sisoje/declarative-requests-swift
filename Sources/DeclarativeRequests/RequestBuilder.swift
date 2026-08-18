import Foundation

@_documentation(visibility: internal)
@resultBuilder
public struct RequestBuilder {}

public extension RequestBuilder {
    @available(*, unavailable, message: "This type is not supported in request builder")
    static func buildExpression<Unsupported>(_: Unsupported) -> RequestBlock {
        fatalError()
    }

    static func buildBlock(_ components: any RequestBuildable...) -> RequestBlock {
        let transforms = components.map(\.transform)
        return RequestBlock { state in
            for transform in transforms {
                try transform(state)
            }
        }
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
        RequestBlock(component?.transform ?? { @Sendable _ in })
    }

    static func buildArray(_ components: [any RequestBuildable]) -> RequestBlock {
        let transforms = components.map(\.transform)
        return RequestBlock { state in
            for transform in transforms {
                try transform(state)
            }
        }
    }

    static func buildLimitedAvailability(_ component: any RequestBuildable) -> RequestBlock {
        RequestBlock(component.transform)
    }
}

// MultipartPart content kind — same builder, contextual return type picks the family.
public extension RequestBuilder {
    static func buildExpression(_ part: MultipartPart) -> [MultipartPart] {
        [part]
    }

    static func buildExpression(_ parts: [MultipartPart]) -> [MultipartPart] {
        parts
    }

    static func buildBlock(_ parts: [MultipartPart]...) -> [MultipartPart] {
        parts.flatMap { $0 }
    }

    static func buildOptional(_ parts: [MultipartPart]?) -> [MultipartPart] {
        parts ?? []
    }

    static func buildEither(first parts: [MultipartPart]) -> [MultipartPart] {
        parts
    }

    static func buildEither(second parts: [MultipartPart]) -> [MultipartPart] {
        parts
    }

    static func buildArray(_ parts: [[MultipartPart]]) -> [MultipartPart] {
        parts.flatMap { $0 }
    }
}
