import Foundation

public enum MIMEType: String {
    case json = "application/json"
    case xml = "application/xml"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case jsonPatch = "application/json-patch+json"
    case mergePatch = "application/merge-patch+json"
    case octetStream = "application/octet-stream"
    case pdf = "application/pdf"
    case zip = "application/zip"
    case gzip = "application/gzip"

    case plainText = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case csv = "text/csv"
    case javascript = "text/javascript"
    case markdown = "text/markdown"
    case eventStream = "text/event-stream"
    case calendar = "text/calendar"

    case png = "image/png"
    case jpeg = "image/jpeg"
    case gif = "image/gif"
    case webp = "image/webp"
    case svg = "image/svg+xml"
    case tiff = "image/tiff"
    case ico = "image/vnd.microsoft.icon"

    case mp3 = "audio/mpeg"
    case wav = "audio/wav"
    case aac = "audio/aac"
    case m4a = "audio/mp4"

    case mp4 = "video/mp4"
    case mpeg = "video/mpeg"
    case webm = "video/webm"
    case quicktime = "video/quicktime"

    case formData = "multipart/form-data"

    case woff = "font/woff"
    case woff2 = "font/woff2"
    case ttf = "font/ttf"
    case otf = "font/otf"
}

public extension MIMEType {
    var accept: some RequestBuildable {
        Header.accept.addValue(rawValue)
    }

    var contentType: some RequestBuildable {
        Header.contentType.setValue(rawValue)
    }
}
