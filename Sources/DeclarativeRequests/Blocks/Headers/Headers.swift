import Foundation

@_documentation(visibility: internal)
public protocol HeaderBuildable: RequestBuildable {}

@_documentation(visibility: internal)
public enum HeaderMode: Sendable, Hashable {
    case set
    case add
}

@_documentation(visibility: internal)
public struct RawHeader: HeaderBuildable {
    let perform: RequestStateTransformClosure

    init(_ perform: @escaping RequestStateTransformClosure) {
        self.perform = perform
    }

    public var body: some RequestBuildable {
        RequestBlock(perform)
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
    var mode: HeaderMode { get }
    init(value: String, mode: HeaderMode)
}

public extension SingleValueHeader {
    func appending() -> Self {
        Self(value: value, mode: .add)
    }

    func replacing() -> Self {
        Self(value: value, mode: .set)
    }

    var body: some RequestBuildable {
        mode == .set
            ? Self.headerName.setValue(value)
            : Self.headerName.addValue(value)
    }
}
