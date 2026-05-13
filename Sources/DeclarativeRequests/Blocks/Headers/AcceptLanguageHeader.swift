import Foundation

public struct AcceptLanguageHeader: SingleValueHeader {
    public static var headerName: Header { .acceptLanguage }
    public let value: String

    @_documentation(visibility: internal)
    public init(value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.init(value: value)
    }

    public init(_ language: Locale.Language) {
        self.init(value: language.minimalIdentifier)
    }

    public func quality(_ q: Double) -> AcceptLanguageHeader {
        let clamped = max(0, min(1, q))
        let qString = String(format: "%g", clamped)
        let base = value.split(separator: ";", maxSplits: 1).first.map(String.init) ?? value
        return AcceptLanguageHeader(value: "\(base);q=\(qString)")
    }
}
