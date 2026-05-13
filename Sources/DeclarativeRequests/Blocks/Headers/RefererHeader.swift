import Foundation

public struct RefererHeader: SingleValueHeader {
    public static var headerName: Header { .referer }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.init(value: value)
    }
}
