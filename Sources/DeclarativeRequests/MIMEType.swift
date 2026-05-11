import Foundation

public struct MIMEType: RawRepresentable, Hashable, Sendable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MIMEType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension MIMEType: CustomStringConvertible {
    public var description: String { rawValue }
}

extension MIMEType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension MIMEType {

    public var essence: String {
        rawValue.split(separator: ";", maxSplits: 1).first.map(String.init)?
            .trimmingCharacters(in: .whitespaces).lowercased() ?? rawValue
    }

    public var type: String? {
        essence.split(separator: "/", maxSplits: 1).first.map(String.init)
    }

    public var subtype: String? {
        let parts = essence.split(separator: "/", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : nil
    }

    public var parameters: [String: String] {
        var result: [String: String] = [:]
        let segments = rawValue.split(separator: ";").dropFirst()
        for segment in segments {
            let pair = segment.split(separator: "=", maxSplits: 1)
            guard pair.count == 2 else { continue }
            let key = pair[0].trimmingCharacters(in: .whitespaces).lowercased()
            let value = pair[1].trimmingCharacters(in: .whitespaces)
            result[key] = value
        }
        return result
    }

    public func matches(_ other: MIMEType) -> Bool {
        essence == other.essence
    }
}

extension MIMEType {
    public static let json: MIMEType            = Application.json
    public static let xml: MIMEType             = Application.xml
    public static let html: MIMEType            = Text.html
    public static let plainText: MIMEType       = Text.plain
    public static let formURLEncoded: MIMEType  = Application.formURLEncoded
    public static let octetStream: MIMEType     = Application.octetStream
    public static let pdf: MIMEType             = Application.pdf
    public static let png: MIMEType             = Image.png
    public static let jpeg: MIMEType            = Image.jpeg
}

extension MIMEType {
    public enum Application {
        public static let json: MIMEType            = "application/json"
        public static let xml: MIMEType             = "application/xml"
        public static let formURLEncoded: MIMEType  = "application/x-www-form-urlencoded"
        public static let octetStream: MIMEType     = "application/octet-stream"
        public static let pdf: MIMEType             = "application/pdf"
        public static let zip: MIMEType             = "application/zip"
        public static let gzip: MIMEType            = "application/gzip"
        public static let javascript: MIMEType      = "application/javascript"
        public static let yaml: MIMEType            = "application/yaml"
        public static let wasm: MIMEType            = "application/wasm"
        public static let graphql: MIMEType         = "application/graphql"

        public static let jsonPatch: MIMEType       = "application/json-patch+json"
        public static let mergePatch: MIMEType      = "application/merge-patch+json"
        public static let problemJSON: MIMEType     = "application/problem+json"
        public static let ldJSON: MIMEType          = "application/ld+json"
        public static let vendorAPIJSON: MIMEType   = "application/vnd.api+json"
        public static let halJSON: MIMEType         = "application/hal+json"

        public static let atomXML: MIMEType         = "application/atom+xml"
        public static let rssXML: MIMEType          = "application/rss+xml"
        public static let soapXML: MIMEType         = "application/soap+xml"

        public static let msword: MIMEType          = "application/msword"
        public static let docx: MIMEType            = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        public static let xls: MIMEType             = "application/vnd.ms-excel"
        public static let xlsx: MIMEType            = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        public static let ppt: MIMEType             = "application/vnd.ms-powerpoint"
        public static let pptx: MIMEType            = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        public static let rtf: MIMEType             = "application/rtf"

        public static let tar: MIMEType             = "application/x-tar"
        public static let sevenZip: MIMEType        = "application/x-7z-compressed"
        public static let rar: MIMEType             = "application/vnd.rar"
    }
}

extension MIMEType {
    public enum Text {
        public static let plain: MIMEType           = "text/plain"
        public static let html: MIMEType            = "text/html"
        public static let css: MIMEType             = "text/css"
        public static let csv: MIMEType             = "text/csv"
        public static let tsv: MIMEType             = "text/tab-separated-values"
        public static let javascript: MIMEType      = "text/javascript"
        public static let xml: MIMEType             = "text/xml"
        public static let markdown: MIMEType        = "text/markdown"
        public static let eventStream: MIMEType     = "text/event-stream"
        public static let vcard: MIMEType           = "text/vcard"
        public static let calendar: MIMEType        = "text/calendar"
        public static let yaml: MIMEType            = "text/yaml"
    }
}

extension MIMEType {
    public enum Image {
        public static let png: MIMEType             = "image/png"
        public static let jpeg: MIMEType            = "image/jpeg"
        public static let gif: MIMEType             = "image/gif"
        public static let webp: MIMEType            = "image/webp"
        public static let svg: MIMEType             = "image/svg+xml"
        public static let bmp: MIMEType             = "image/bmp"
        public static let tiff: MIMEType            = "image/tiff"
        public static let heic: MIMEType            = "image/heic"
        public static let heif: MIMEType            = "image/heif"
        public static let avif: MIMEType            = "image/avif"
        public static let ico: MIMEType             = "image/vnd.microsoft.icon"
    }
}

extension MIMEType {
    public enum Audio {
        public static let mpeg: MIMEType            = "audio/mpeg"
        public static let wav: MIMEType             = "audio/wav"
        public static let ogg: MIMEType             = "audio/ogg"
        public static let webm: MIMEType            = "audio/webm"
        public static let aac: MIMEType             = "audio/aac"
        public static let flac: MIMEType            = "audio/flac"
        public static let mp4: MIMEType             = "audio/mp4"
        public static let opus: MIMEType            = "audio/opus"
    }
}

extension MIMEType {
    public enum Video {
        public static let mp4: MIMEType             = "video/mp4"
        public static let webm: MIMEType            = "video/webm"
        public static let ogg: MIMEType             = "video/ogg"
        public static let mpeg: MIMEType            = "video/mpeg"
        public static let quicktime: MIMEType       = "video/quicktime"
        public static let avi: MIMEType             = "video/x-msvideo"
        public static let mkv: MIMEType             = "video/x-matroska"
    }
}

extension MIMEType {
    public enum Multipart {
        public static let formData: MIMEType        = "multipart/form-data"
        public static let mixed: MIMEType           = "multipart/mixed"
        public static let alternative: MIMEType     = "multipart/alternative"
        public static let related: MIMEType         = "multipart/related"
        public static let byteranges: MIMEType      = "multipart/byteranges"
        public static let digest: MIMEType          = "multipart/digest"
        public static let parallel: MIMEType        = "multipart/parallel"

        public static func formData(boundary: String) -> MIMEType {
            formData.with(.boundary(boundary))
        }
    }
}

extension MIMEType {
    public enum Font {
        public static let woff: MIMEType            = "font/woff"
        public static let woff2: MIMEType           = "font/woff2"
        public static let ttf: MIMEType             = "font/ttf"
        public static let otf: MIMEType             = "font/otf"
        public static let collection: MIMEType      = "font/collection"
    }
}
