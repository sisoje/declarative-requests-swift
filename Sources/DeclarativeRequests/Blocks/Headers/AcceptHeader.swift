import Foundation

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

    public func quality(_ q: Double) -> AcceptHeader {
        let parts = value.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        let base = parts.first ?? value
        let preserved = parts.dropFirst().filter { !$0.lowercased().hasPrefix("q=") }
        let withoutQ = ([base] + preserved).joined(separator: "; ")
        return AcceptHeader(value: MIMEType(withoutQ).with(.quality(q)).rawValue, mode: mode)
    }
}
