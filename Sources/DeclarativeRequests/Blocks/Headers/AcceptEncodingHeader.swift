import Foundation

public struct AcceptEncodingHeader: SingleValueHeader {
    public static var headerName: Header { .acceptEncoding }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.init(value: value)
    }
}
