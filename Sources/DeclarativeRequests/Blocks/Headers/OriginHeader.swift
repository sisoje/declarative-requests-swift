import Foundation

public struct OriginHeader: SingleValueHeader {
    public static var headerName: Header { .origin }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.init(value: value)
    }
}
