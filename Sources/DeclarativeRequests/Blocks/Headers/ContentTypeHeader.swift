import Foundation

public struct ContentTypeHeader: SingleValueHeader {
    public static var headerName: Header { .contentType }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ mimeType: MIMEType) {
        self.init(value: mimeType.rawValue)
    }

    public init(_ raw: String) {
        self.init(value: raw)
    }
}
