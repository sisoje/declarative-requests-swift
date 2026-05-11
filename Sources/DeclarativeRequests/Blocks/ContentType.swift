import Foundation

/// A typed identifier for an HTTP `Content-Type` value.
///
/// Used directly as a block to set the `Content-Type` header, and as a
/// parameter on body blocks like ``RequestBody`` and ``MultipartPart`` to
/// label payload bytes:
///
/// ```swift
/// // As a block:
/// ContentType.JSON  // sets Content-Type: application/json
///
/// // As a value passed to other blocks:
/// RequestBody.data(svgData, type: .SVG)
/// MultipartPart.data(name: "avatar", filename: "a.png", data: png, type: .PNG)
/// ```
public enum ContentType: String, RequestBuildable {
    // MARK: Application

    /// `application/x-www-form-urlencoded`
    case URLEncoded = "application/x-www-form-urlencoded"
    /// `application/json`
    case JSON = "application/json"
    /// `application/octet-stream`
    case Stream = "application/octet-stream"
    /// `application/pdf`
    case PDF = "application/pdf"
    /// `application/xml`
    case XML = "application/xml"
    /// `application/zip`
    case ZIP = "application/zip"
    /// `application/x-7z-compressed`
    case ZIP7 = "application/x-7z-compressed"
    /// `application/gzip`
    case GZIP = "application/gzip"
    /// `application/msword`
    case DOC = "application/msword"
    /// `application/vnd.ms-excel`
    case XLS = "application/vnd.ms-excel"
    /// `application/vnd.ms-powerpoint`
    case PPT = "application/vnd.ms-powerpoint"
    /// `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
    case DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    /// `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
    case XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    /// `application/vnd.openxmlformats-officedocument.presentationml.presentation`
    case PPTX = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    /// `application/x-mpegURL`
    case M3U8 = "application/x-mpegURL"

    // MARK: Text

    /// `text/html`
    case HTML = "text/html"
    /// `text/plain`
    case PlainText = "text/plain"
    /// `text/css`
    case CSS = "text/css"
    /// `text/csv`
    case CSV = "text/csv"
    /// `text/javascript`
    case JS = "text/javascript"
    /// `text/calendar`
    case Calendar = "text/calendar"

    // MARK: Image

    /// `image/jpeg`
    case JPEG = "image/jpeg"
    /// `image/png`
    case PNG = "image/png"
    /// `image/gif`
    case GIF = "image/gif"
    /// `image/svg+xml`
    case SVG = "image/svg+xml"
    /// `image/webp`
    case WebP = "image/webp"
    /// `image/tiff`
    case TIFF = "image/tiff"
    /// `image/bmp`
    case BMP = "image/bmp"
    /// `image/vnd.microsoft.icon`
    case ICO = "image/vnd.microsoft.icon"

    // MARK: Audio

    /// `audio/mpeg`
    case MP3 = "audio/mpeg"
    /// `audio/wav`
    case WAV = "audio/wav"
    /// `audio/ogg`
    case OGGAudio = "audio/ogg"
    /// `audio/aac`
    case AAC = "audio/aac"
    /// `audio/mp4`
    case M4A = "audio/mp4"
    /// `audio/midi`
    case MIDI = "audio/midi"
    /// `audio/mpegURL`
    case M3U = "audio/mpegURL"

    // MARK: Video

    /// `video/mp4`
    case MP4 = "video/mp4"
    /// `video/mpeg`
    case MPEG = "video/mpeg"
    /// `video/webm`
    case WebM = "video/webm"
    /// `video/ogg`
    case OGGVideo = "video/ogg"
    /// `video/x-msvideo`
    case AVI = "video/x-msvideo"
    /// `video/mp2t`
    case TS = "video/mp2t"

    // MARK: Font

    /// `font/woff`
    case WOFF = "font/woff"
    /// `font/woff2`
    case WOFF2 = "font/woff2"
    /// `font/ttf`
    case TTF = "font/ttf"
    /// `font/otf`
    case OTF = "font/otf"

    public var body: some RequestBuildable {
        Header.contentType.setValue(rawValue)
    }
}
