import Foundation

@_documentation(visibility: internal)
public protocol HeaderBuildable: RequestBuildable {}

public extension HeaderBuildable {
    func headersAdd() -> some HeaderBuildable {
        HeaderModeOverride(inner: self, shouldAdd: true)
    }

    func headersSet() -> some HeaderBuildable {
        HeaderModeOverride(inner: self, shouldAdd: false)
    }
}

@_documentation(visibility: internal)
public struct HeaderModeOverride<Inner: HeaderBuildable>: HeaderBuildable {
    let inner: Inner
    let shouldAdd: Bool

    public var body: some RequestBuildable {
        inner.environment(\.shouldAddHeaders, shouldAdd)
    }
}

public struct Headers: RequestBuildable {
    let blocks: [any HeaderBuildable]

    public init(@HeadersBuilder _ content: () -> [any HeaderBuildable]) {
        blocks = content()
    }

    public var body: some RequestBuildable {
        RequestBlock(blocks.map(\.transform).reduced)
    }
}

@_documentation(visibility: internal)
@resultBuilder
public enum HeadersBuilder {
    public static func buildExpression(_ expression: any HeaderBuildable) -> [any HeaderBuildable] {
        [expression]
    }

    @available(*, unavailable, message: "Headers { } only accepts HeaderBuildable values")
    public static func buildExpression<Unsupported>(_: Unsupported) -> [any HeaderBuildable] {
        fatalError()
    }

    public static func buildBlock(_ parts: [any HeaderBuildable]...) -> [any HeaderBuildable] {
        parts.flatMap { $0 }
    }

    public static func buildOptional(_ component: [any HeaderBuildable]?) -> [any HeaderBuildable] {
        component ?? []
    }

    public static func buildEither(first component: [any HeaderBuildable]) -> [any HeaderBuildable] {
        component
    }

    public static func buildEither(second component: [any HeaderBuildable]) -> [any HeaderBuildable] {
        component
    }

    public static func buildArray(_ components: [[any HeaderBuildable]]) -> [any HeaderBuildable] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any HeaderBuildable]) -> [any HeaderBuildable] {
        component
    }
}

@_documentation(visibility: internal)
public protocol SingleValueHeader: HeaderBuildable {
    static var headerName: Header { get }
    var value: String { get }
    init(value: String)
}

public extension SingleValueHeader {
    var body: some RequestBuildable {
        RequestBlock { state in
            let shouldAdd = state.shouldAddHeaders ?? false
            if shouldAdd {
                state.request.addValue(value, forHTTPHeaderField: Self.headerName.rawValue)
            } else {
                state.request.setValue(value, forHTTPHeaderField: Self.headerName.rawValue)
            }
        }
    }
}
