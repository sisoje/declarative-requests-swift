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

public struct AcceptHeader: SingleValueHeader {
    public static var headerName: Header { .accept }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ mimeType: MIMEType) {
        self.init(value: mimeType.rawValue, mode: .set)
    }

    public init(_ raw: String) {
        self.init(value: raw, mode: .set)
    }
}

public struct ContentTypeHeader: SingleValueHeader {
    public static var headerName: Header { .contentType }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ mimeType: MIMEType) {
        self.init(value: mimeType.rawValue, mode: .set)
    }

    public init(_ raw: String) {
        self.init(value: raw, mode: .set)
    }
}

public struct UserAgentHeader: SingleValueHeader {
    public static var headerName: Header { .userAgent }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }
}

public enum AuthorizationHeader {
    public static func raw(_ value: String) -> some HeaderBuildable {
        Header.authorization.setValue(value)
    }

    public static func bearer(_ token: String) -> some HeaderBuildable {
        Header.authorization.setValue("Bearer \(token)")
    }

    public static func token(_ token: String) -> some HeaderBuildable {
        Header.authorization.setValue("Token \(token)")
    }

    public static func basic(username: String, password: String) -> some HeaderBuildable {
        let encoded = Data("\(username):\(password)".utf8).base64EncodedString()
        return Header.authorization.setValue("Basic \(encoded)")
    }

    public static func scheme(_ scheme: String, value: String) -> some HeaderBuildable {
        Header.authorization.setValue("\(scheme) \(value)")
    }
}

public struct HostHeader: SingleValueHeader {
    public static var headerName: Header { .host }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }
}

public struct OriginHeader: SingleValueHeader {
    public static var headerName: Header { .origin }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }
}

public struct RefererHeader: SingleValueHeader {
    public static var headerName: Header { .referer }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }
}

public struct AcceptLanguageHeader: SingleValueHeader {
    public static var headerName: Header { .acceptLanguage }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }

    public init(_ language: Locale.Language) {
        self.init(value: language.minimalIdentifier, mode: .set)
    }

    public func quality(_ q: Double) -> AcceptLanguageHeader {
        let clamped = max(0, min(1, q))
        let qString = String(format: "%g", clamped)
        let base = value.split(separator: ";", maxSplits: 1).first.map(String.init) ?? value
        return AcceptLanguageHeader(value: "\(base);q=\(qString)", mode: mode)
    }
}

public struct AcceptEncodingHeader: SingleValueHeader {
    public static var headerName: Header { .acceptEncoding }
    public let value: String
    public let mode: HeaderMode

    @_documentation(visibility: internal)
    public init(value: String, mode: HeaderMode) {
        self.value = value
        self.mode = mode
    }

    public init(_ value: String) {
        self.init(value: value, mode: .set)
    }
}

public struct CustomHeader: HeaderBuildable {
    public let name: String
    public let value: String
    public let mode: HeaderMode

    public init(_ name: String, _ value: String) {
        self.init(name: name, value: value, mode: .add)
    }

    init(name: String, value: String, mode: HeaderMode) {
        self.name = name
        self.value = value
        self.mode = mode
    }

    public func appending() -> CustomHeader {
        CustomHeader(name: name, value: value, mode: .add)
    }

    public func replacing() -> CustomHeader {
        CustomHeader(name: name, value: value, mode: .set)
    }

    public var body: some RequestBuildable {
        mode == .set
            ? Header.custom(name).setValue(value)
            : Header.custom(name).addValue(value)
    }
}
