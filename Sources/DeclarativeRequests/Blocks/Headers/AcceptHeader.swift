import Foundation

public struct AcceptHeader: SingleValueHeader {
    public static var headerName: Header { .accept }
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

    public func quality(_ q: Double) -> AcceptHeader {
        let parts = value.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        let base = parts.first ?? value
        let preserved = parts.dropFirst().filter { !$0.lowercased().hasPrefix("q=") }
        let withoutQ = ([base] + preserved).joined(separator: "; ")
        return AcceptHeader(value: MIMEType(withoutQ).with(.quality(q)).rawValue)
    }
}
