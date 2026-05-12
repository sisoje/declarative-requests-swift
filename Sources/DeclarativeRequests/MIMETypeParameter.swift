import Foundation

public extension MIMEType {
    struct Parameter: Hashable, Sendable {
        public let name: String
        public let value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }

        public var rawValue: String {
            "\(name)=\(value)"
        }
    }
}

public extension MIMEType.Parameter {
    static func charset(_ charset: MIMEType.Charset) -> Self {
        Self(name: "charset", value: charset.rawValue)
    }

    static func charset(_ raw: String) -> Self {
        Self(name: "charset", value: raw)
    }

    static func quality(_ q: Double) -> Self {
        Self(name: "q", value: formatQuality(q))
    }

    static func boundary(_ value: String) -> Self {
        Self(name: "boundary", value: value)
    }

    static func version(_ value: String) -> Self {
        Self(name: "version", value: value)
    }

    static func profile(_ value: String) -> Self {
        Self(name: "profile", value: value)
    }

    static func custom(_ name: String, _ value: String) -> Self {
        Self(name: name, value: value)
    }

    private static func formatQuality(_ q: Double) -> String {
        let clamped = max(0, min(1, q))
        var s = String(format: "%.3f", clamped)
        while s.hasSuffix("0") {
            s.removeLast()
        }
        if s.hasSuffix(".") { s.removeLast() }
        return s
    }
}

public extension MIMEType {
    struct Charset: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            rawValue = value
        }

        public static let utf8: Charset = "utf-8"
        public static let utf16: Charset = "utf-16"
        public static let utf16LE: Charset = "utf-16le"
        public static let utf16BE: Charset = "utf-16be"
        public static let utf32: Charset = "utf-32"
        public static let asciiUS: Charset = "us-ascii"
        public static let iso88591: Charset = "iso-8859-1"
        public static let iso885915: Charset = "iso-8859-15"
        public static let windows1252: Charset = "windows-1252"
        public static let shiftJIS: Charset = "shift_jis"
        public static let gb2312: Charset = "gb2312"
        public static let big5: Charset = "big5"
        public static let eucKR: Charset = "euc-kr"
    }
}

public extension MIMEType {
    func with(_ parameter: Parameter) -> MIMEType {
        MIMEType("\(rawValue); \(parameter.rawValue)")
    }

    func with(_ parameters: Parameter...) -> MIMEType {
        with(parameters)
    }

    func with(_ parameters: [Parameter]) -> MIMEType {
        guard !parameters.isEmpty else { return self }
        let suffix = parameters.map(\.rawValue).joined(separator: "; ")
        return MIMEType("\(rawValue); \(suffix)")
    }
}

public extension MIMEType {
    struct List: Hashable, Sendable, ExpressibleByArrayLiteral {
        public var items: [MIMEType]

        public init(_ items: [MIMEType]) {
            self.items = items
        }

        public init(_ items: MIMEType...) {
            self.items = items
        }

        public init(arrayLiteral elements: MIMEType...) {
            items = elements
        }

        public var rawValue: String {
            items.map(\.rawValue).joined(separator: ", ")
        }
    }
}

extension MIMEType.List: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
