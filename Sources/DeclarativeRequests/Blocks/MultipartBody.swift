import Foundation

/// A single piece of a `multipart/form-data` payload.
///
/// Use the case constructors inside a ``MultipartBody`` block:
///
/// ```swift
/// MultipartBody {
///     MultipartPart.field(name: "user", value: "alice")
///     MultipartPart.data(name: "avatar", filename: "a.png", data: pngBytes, type: .PNG)
///     MultipartPart.file(name: "doc", fileURL: localFile, type: .PDF)
/// }
/// ```
public enum MultipartPart: Sendable {
    /// A simple text field — the multipart equivalent of an HTML
    /// `<input type="text">`.
    /// - Parameters:
    ///   - name: The field name.
    ///   - value: The field value.
    case field(name: String, value: String)

    /// A file part backed by an in-memory `Data` blob.
    /// - Parameters:
    ///   - name: The field name.
    ///   - filename: The filename to advertise to the server.
    ///   - data: The raw bytes.
    ///   - type: The content type. Defaults to ``ContentType/Stream``
    ///     (`application/octet-stream`).
    case data(name: String, filename: String, data: Data, type: ContentType = .Stream)

    /// A file part loaded from disk at build time.
    ///
    /// The file is read synchronously when the request is built; failures
    /// surface as ``DeclarativeRequestsError/badMultipart(reason:)``.
    ///
    /// - Parameters:
    ///   - name: The field name.
    ///   - fileURL: A `file://` URL pointing at the file to upload.
    ///   - type: The content type. Defaults to ``ContentType/Stream``.
    ///   - filename: The filename to advertise to the server. Defaults to the
    ///     `lastPathComponent` of `fileURL`.
    case file(name: String, fileURL: URL, type: ContentType = .Stream, filename: String? = nil)

    func append(to form: inout MultipartForm) throws {
        switch self {
        case .field(let name, let value):
            form.addField(named: name, value: value)
        case .data(let name, let filename, let payload, let type):
            form.addFile(named: name, filename: filename, data: payload, mimeType: type.rawValue)
        case .file(let name, let fileURL, let type, let filename):
            let bytes: Data
            do {
                bytes = try Data(contentsOf: fileURL)
            } catch {
                throw DeclarativeRequestsError.badMultipart(reason: "Could not read \(fileURL.lastPathComponent): \(error.localizedDescription)")
            }
            form.addFile(
                named: name,
                filename: filename ?? fileURL.lastPathComponent,
                data: bytes,
                mimeType: type.rawValue
            )
        }
    }
}

/// Result builder for assembling `[MultipartPart]`.
///
/// Mirrors the shape of ``RequestBuilder`` so all the structural Swift forms
/// work inside a ``MultipartBody`` block:
///
/// ```swift
/// MultipartBody {
///     MultipartPart.field(name: "always", value: "yes")
///
///     if let avatar {
///         MultipartPart.data(name: "avatar", filename: "a.png", data: avatar, type: .PNG)
///     }
///
///     for tag in tags {
///         MultipartPart.field(name: "tag", value: tag)
///     }
/// }
/// ```
@resultBuilder
public enum MultipartBuilder {
    /// Combine the per-statement results into a single flat array.
    public static func buildBlock(_ components: [MultipartPart]...) -> [MultipartPart] {
        components.flatMap { $0 }
    }

    /// Lift a single `MultipartPart` value into the builder.
    public static func buildExpression(_ part: MultipartPart) -> [MultipartPart] {
        [part]
    }

    /// Lift a `[MultipartPart]` value into the builder.
    public static func buildExpression(_ parts: [MultipartPart]) -> [MultipartPart] {
        parts
    }

    /// Build an `if` statement without an `else`.
    public static func buildOptional(_ component: [MultipartPart]?) -> [MultipartPart] {
        component ?? []
    }

    /// Build the `if` branch of an `if`-`else`.
    public static func buildEither(first component: [MultipartPart]) -> [MultipartPart] {
        component
    }

    /// Build the `else` branch of an `if`-`else`.
    public static func buildEither(second component: [MultipartPart]) -> [MultipartPart] {
        component
    }

    /// Build a `for`-`in` loop.
    public static func buildArray(_ components: [[MultipartPart]]) -> [MultipartPart] {
        components.flatMap { $0 }
    }

    /// Erase a partial result wrapped by `if #available`.
    public static func buildLimitedAvailability(_ component: [MultipartPart]) -> [MultipartPart] {
        component
    }
}

/// Builds a `multipart/form-data` body and sets the matching `Content-Type` header.
///
/// `MultipartBody` assembles the entire payload in memory at build time. For
/// uploads small enough to comfortably hold in RAM, that's the simplest option;
/// for very large uploads, prefer ``StreamBody`` and stream from a file or
/// custom `InputStream`.
///
/// ```swift
/// let request = try URLRequest {
///     Method.POST
///     BaseURL("https://api.example.com")
///     Endpoint("/upload")
///     MultipartBody {
///         MultipartPart.field(name: "user", value: "alice")
///         MultipartPart.data(name: "avatar", filename: "a.png", data: png, type: .PNG)
///         for url in fileURLs {
///             MultipartPart.file(name: "files", fileURL: url, type: .Stream)
///         }
///     }
/// }
/// ```
///
/// A fresh boundary token is generated per instance unless you supply one.
/// You'd typically only set the boundary explicitly in tests, where a stable
/// boundary makes assertions easier.
public struct MultipartBody: RequestBuildable, Sendable {
    let parts: [MultipartPart]
    let boundary: String

    /// Create a `MultipartBody` from a builder closure.
    ///
    /// - Parameters:
    ///   - boundary: The multipart boundary token. Defaults to a random
    ///     `Boundary-<UUID>` value.
    ///   - parts: A `@MultipartBuilder` closure that produces the parts.
    public init(boundary: String? = nil, @MultipartBuilder _ parts: () -> [MultipartPart]) {
        self.parts = parts()
        self.boundary = boundary ?? "Boundary-\(UUID().uuidString)"
    }

    /// Create a `MultipartBody` from an explicit `[MultipartPart]` array.
    ///
    /// - Parameters:
    ///   - parts: The parts to include.
    ///   - boundary: The multipart boundary token. Defaults to a random
    ///     `Boundary-<UUID>` value.
    public init(_ parts: [MultipartPart], boundary: String? = nil) {
        self.parts = parts
        self.boundary = boundary ?? "Boundary-\(UUID().uuidString)"
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            var form = MultipartForm(boundary: boundary)
            for part in parts {
                try part.append(to: &form)
            }
            state.request.httpBody = form.bodyData
            state.request.setValue(form.contentType, forHTTPHeaderField: Header.contentType.rawValue)
        }
    }
}

struct MultipartForm {
    let boundary: String
    private var data = Data()

    init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }

    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    mutating func addField(named name: String, value: String) {
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        data.append("\(value)\r\n")
    }

    mutating func addFile(named name: String, filename: String, data fileData: Data, mimeType: String) {
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        data.append("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
    }

    var bodyData: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--\r\n")
        return bodyData
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
