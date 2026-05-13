import Foundation

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
