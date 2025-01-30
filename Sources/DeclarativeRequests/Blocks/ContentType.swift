import Foundation

public enum ContentType: String, CompositeNode {
    // Application types
    case URLEncoded = "application/x-www-form-urlencoded"
    case JSON = "application/json"
    case Stream = "application/octet-stream"
    case PDF = "application/pdf"
    case XMLData = "application/xml"
    case ZIP = "application/zip"
    case ZIP7 = "application/x-7z-compressed"
    case GZIP = "application/gzip"
    case MSWord = "application/msword"
    case MSExcel = "application/vnd.ms-excel"
    case MSPowerPoint = "application/vnd.ms-powerpoint"
    case WordOpenXML = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case ExcelOpenXML = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case PowerPointOpenXML = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case M3U8 = "application/x-mpegURL"

    // Text types
    case HTML = "text/html"
    case PlainText = "text/plain"
    case CSS = "text/css"
    case CSV = "text/csv"
    case JavaScript = "text/javascript"
    case Calendar = "text/calendar"

    // Image types
    case JPEG = "image/jpeg"
    case PNG = "image/png"
    case GIF = "image/gif"
    case SVG = "image/svg+xml"
    case WebP = "image/webp"
    case TIFF = "image/tiff"
    case BMP = "image/bmp"
    case ICO = "image/vnd.microsoft.icon"

    // Audio types
    case MP3 = "audio/mpeg"
    case WAV = "audio/wav"
    case OGGAudio = "audio/ogg"
    case AAC = "audio/aac"
    case M4A = "audio/mp4"
    case MIDI = "audio/midi"
    case M3U = "audio/mpegURL"

    // Video types
    case MP4 = "video/mp4"
    case MPEG = "video/mpeg"
    case WebM = "video/webm"
    case OGGVideo = "video/ogg"
    case AVI = "video/x-msvideo"
    case TS = "video/mp2t"

    // Font types
    case WOFF = "font/woff"
    case WOFF2 = "font/woff2"
    case TTF = "font/ttf"
    case OTF = "font/otf"

    public var body: some BuilderNode {
        Header.contentType.setValue(rawValue)
    }
}
