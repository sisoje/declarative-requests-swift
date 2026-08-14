import Foundation

public enum MIMEType {
    case json
    case xml
    case formURLEncoded
    case jsonPatch
    case mergePatch
    case octetStream
    case pdf
    case zip
    case gzip
    case plainText
    case html
    case csv
    case markdown
    case eventStream
    case calendar
    case png
    case jpeg
    case heic
    case gif
    case webp
    case svg
    case tiff
    case mp3
    case wav
    case aac
    case m4a
    case mp4
    case mpeg
    case webm
    case quicktime
    case custom(String)

    public var rawValue: String {
        switch self {
        case .json: "application/json"
        case .xml: "application/xml"
        case .formURLEncoded: "application/x-www-form-urlencoded"
        case .jsonPatch: "application/json-patch+json"
        case .mergePatch: "application/merge-patch+json"
        case .octetStream: "application/octet-stream"
        case .pdf: "application/pdf"
        case .zip: "application/zip"
        case .gzip: "application/gzip"
        case .plainText: "text/plain"
        case .html: "text/html"
        case .csv: "text/csv"
        case .markdown: "text/markdown"
        case .eventStream: "text/event-stream"
        case .calendar: "text/calendar"
        case .png: "image/png"
        case .jpeg: "image/jpeg"
        case .heic: "image/heic"
        case .gif: "image/gif"
        case .webp: "image/webp"
        case .svg: "image/svg+xml"
        case .tiff: "image/tiff"
        case .mp3: "audio/mpeg"
        case .wav: "audio/wav"
        case .aac: "audio/aac"
        case .m4a: "audio/mp4"
        case .mp4: "video/mp4"
        case .mpeg: "video/mpeg"
        case .webm: "video/webm"
        case .quicktime: "video/quicktime"
        case let .custom(value): value
        }
    }

    public var accept: some RequestBuildable {
        Header.accept.addValue(rawValue)
    }

    public var contentType: some RequestBuildable {
        Header.contentType.setValue(rawValue)
    }
}
