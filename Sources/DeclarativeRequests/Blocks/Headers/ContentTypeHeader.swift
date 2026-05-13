import Foundation

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
