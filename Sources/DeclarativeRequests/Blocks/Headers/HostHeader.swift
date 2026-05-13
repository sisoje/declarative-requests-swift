import Foundation

public struct HostHeader: SingleValueHeader {
    public static var headerName: Header { .host }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.init(value: value)
    }
}
