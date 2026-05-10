import Foundation

// MARK: - Public API

public extension RequestBody {
    /// How the multipart body bytes are produced.
    enum MultipartStrategy {
        /// Assemble the entire payload in memory, then set it as `httpBody`.
        /// Simple, but holds the whole body in RAM.
        case inMemory

        /// Stream the payload from disk on demand. Memory use stays bounded to
        /// roughly `bufferSize` regardless of total payload size, so payloads
        /// in the hundreds of gigabytes are practical.
        ///
        /// - Parameter bufferSize: The chunk size used for both the bound
        ///   stream pair and for reading from disk. Defaults to 64 KB.
        case streamed(bufferSize: Int = 64 * 1024)
    }

    /// A `multipart/form-data` body assembled from the supplied parts.
    ///
    /// ```swift
    /// RequestBody.multipart {
    ///     MultipartPart.field(name: "user", value: "alice")
    ///     MultipartPart.data(name: "avatar", filename: "a.png", data: png, type: .PNG)
    ///     for url in fileURLs {
    ///         MultipartPart.file(name: "files", fileURL: url, type: .Stream)
    ///     }
    /// }
    /// ```
    ///
    /// Sets `Content-Type: multipart/form-data; boundary=…`. With
    /// ``MultipartStrategy/streamed(bufferSize:)`` it also sets
    /// `Content-Length` and `httpBodyStream` instead of `httpBody`.
    ///
    /// - Parameters:
    ///   - boundary: The multipart boundary token. Defaults to a random
    ///     `Boundary-<UUID>` value.
    ///   - strategy: Whether to assemble in memory (default) or stream from
    ///     disk for very large payloads.
    ///   - parts: A `@MultipartBuilder` closure that produces the parts.
    static func multipart(
        boundary: String? = nil,
        strategy: MultipartStrategy = .inMemory,
        @MultipartBuilder _ parts: () -> [MultipartPart]
    ) -> some RequestBuildable {
        let parts = parts()
        let boundary = boundary ?? "Boundary-\(UUID().uuidString)"
        return RequestBlock { state in
            switch strategy {
            case .inMemory:
                try applyInMemory(parts: parts, boundary: boundary, state: state)
            case .streamed(let bufferSize):
                try applyStreamed(parts: parts, boundary: boundary, bufferSize: bufferSize, state: state)
            }
        }
    }
}

/// A single piece of a `multipart/form-data` payload.
///
/// Use the case constructors inside a ``RequestBody/multipart(boundary:strategy:_:)``
/// block:
///
/// ```swift
/// RequestBody.multipart {
///     MultipartPart.field(name: "user", value: "alice")
///     MultipartPart.data(name: "avatar", filename: "a.png", data: pngBytes, type: .PNG)
///     MultipartPart.file(name: "doc", fileURL: localFile, type: .PDF)
/// }
/// ```
public enum MultipartPart {
    /// A simple text field — the multipart equivalent of an HTML
    /// `<input type="text">`.
    case field(name: String, value: String)

    /// A file part backed by an in-memory `Data` blob.
    case data(name: String, filename: String, data: Data, type: ContentType = .Stream)

    /// A file part loaded from disk (or streamed, depending on strategy).
    case file(name: String, fileURL: URL, type: ContentType = .Stream, filename: String? = nil)
}

/// Result builder for assembling `[MultipartPart]` inside a ``RequestBody/multipart(boundary:strategy:_:)`` block.
@resultBuilder
public enum MultipartBuilder {
    public static func buildBlock(_ components: [MultipartPart]...) -> [MultipartPart] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ part: MultipartPart) -> [MultipartPart] {
        [part]
    }

    public static func buildExpression(_ parts: [MultipartPart]) -> [MultipartPart] {
        parts
    }

    public static func buildOptional(_ component: [MultipartPart]?) -> [MultipartPart] {
        component ?? []
    }

    public static func buildEither(first component: [MultipartPart]) -> [MultipartPart] {
        component
    }

    public static func buildEither(second component: [MultipartPart]) -> [MultipartPart] {
        component
    }

    public static func buildArray(_ components: [[MultipartPart]]) -> [MultipartPart] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [MultipartPart]) -> [MultipartPart] {
        component
    }
}

// MARK: - In-memory implementation

private func applyInMemory(parts: [MultipartPart], boundary: String, state: RequestState) throws {
    var form = MultipartForm(boundary: boundary)
    for part in parts {
        try part.append(to: &form)
    }
    state.request.httpBody = form.bodyData
    state.request.setValue(form.contentType, forHTTPHeaderField: Header.Field.contentType.rawValue)
}

private extension MultipartPart {
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

private struct MultipartForm {
    let boundary: String
    private var data = Data()

    init(boundary: String) {
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

// MARK: - Streamed implementation

private func applyStreamed(parts: [MultipartPart], boundary: String, bufferSize: Int, state: RequestState) throws {
    let length = try MultipartLength.compute(parts: parts, boundary: boundary)

    var input: InputStream?
    var output: OutputStream?
    Stream.getBoundStreams(
        withBufferSize: bufferSize,
        inputStream: &input,
        outputStream: &output
    )

    guard let input, let output else {
        throw DeclarativeRequestsError.badMultipart(reason: "Could not create bound streams")
    }

    state.request.httpBodyStream = input
    state.request.setValue(
        "multipart/form-data; boundary=\(boundary)",
        forHTTPHeaderField: Header.Field.contentType.rawValue
    )
    state.request.setValue("\(length)", forHTTPHeaderField: "Content-Length")

    MultipartStreamProducer(
        parts: parts,
        boundary: boundary,
        output: output,
        bufferSize: bufferSize
    ).start()
}

private enum MultipartLength {
    static func compute(parts: [MultipartPart], boundary: String) throws -> Int64 {
        var total: Int64 = 0
        for part in parts {
            total += try lengthOf(part: part, boundary: boundary)
        }
        total += Int64("--\(boundary)--\r\n".utf8.count)
        return total
    }

    private static func lengthOf(part: MultipartPart, boundary: String) throws -> Int64 {
        switch part {
        case .field(let name, let value):
            let header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
            return Int64(header.utf8.count) + Int64(value.utf8.count) + 2
        case .data(let name, let filename, let payload, let type):
            let header = fileHeader(name: name, filename: filename, type: type, boundary: boundary)
            return Int64(header.utf8.count) + Int64(payload.count) + 2
        case .file(let name, let fileURL, let type, let filename):
            let resolved = filename ?? fileURL.lastPathComponent
            let header = fileHeader(name: name, filename: resolved, type: type, boundary: boundary)
            let attrs: [FileAttributeKey: Any]
            do {
                attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            } catch {
                throw DeclarativeRequestsError.badMultipart(
                    reason: "Could not stat \(fileURL.lastPathComponent): \(error.localizedDescription)"
                )
            }
            guard let size = (attrs[.size] as? NSNumber)?.int64Value else {
                throw DeclarativeRequestsError.badMultipart(
                    reason: "File \(fileURL.lastPathComponent) has no .size attribute"
                )
            }
            return Int64(header.utf8.count) + size + 2
        }
    }

    static func fileHeader(name: String, filename: String, type: ContentType, boundary: String) -> String {
        "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\nContent-Type: \(type.rawValue)\r\n\r\n"
    }
}

// MARK: - Streamed producer

private final class MultipartStreamProducer: NSObject, StreamDelegate {
    enum Source {
        case data(Data)
        case file(URL)
    }

    private let bufferSize: Int
    private let output: OutputStream
    private var sources: [Source]
    private var sourceIndex: Int = 0
    private var fileStream: InputStream?
    private var pending: (data: Data, offset: Int)?
    private var thread: Thread?
    private var done = false

    init(parts: [MultipartPart], boundary: String, output: OutputStream, bufferSize: Int) {
        self.bufferSize = bufferSize
        self.output = output
        sources = Self.buildSources(parts: parts, boundary: boundary)
    }

    private static func buildSources(parts: [MultipartPart], boundary: String) -> [Source] {
        var sources: [Source] = []
        for part in parts {
            switch part {
            case .field(let name, let value):
                let chunk = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n"
                sources.append(.data(Data(chunk.utf8)))
            case .data(let name, let filename, let payload, let type):
                sources.append(.data(Data(MultipartLength.fileHeader(name: name, filename: filename, type: type, boundary: boundary).utf8)))
                sources.append(.data(payload))
                sources.append(.data(Data("\r\n".utf8)))
            case .file(let name, let fileURL, let type, let filename):
                let resolved = filename ?? fileURL.lastPathComponent
                sources.append(.data(Data(MultipartLength.fileHeader(name: name, filename: resolved, type: type, boundary: boundary).utf8)))
                sources.append(.file(fileURL))
                sources.append(.data(Data("\r\n".utf8)))
            }
        }
        sources.append(.data(Data("--\(boundary)--\r\n".utf8)))
        return sources
    }

    func start() {
        let thread = ProducerThread(producer: self)
        self.thread = thread
        thread.start()
    }

    fileprivate func runOnThread() {
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        while !done {
            RunLoop.current.run(mode: .default, before: Date.distantFuture)
        }
        output.delegate = nil
        thread = nil
    }

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream === output else { return }
        switch eventCode {
        case .hasSpaceAvailable:
            feed()
        case .errorOccurred, .endEncountered:
            finish()
        default:
            break
        }
    }

    private func feed() {
        while !done, output.hasSpaceAvailable {
            if pending == nil {
                guard let next = nextChunk() else {
                    finish()
                    return
                }
                pending = (next, 0)
            }

            guard let chunk = pending else { continue }
            let remaining = chunk.data.count - chunk.offset
            let written = chunk.data.withUnsafeBytes { buf -> Int in
                guard let base = buf.bindMemory(to: UInt8.self).baseAddress else { return -1 }
                return output.write(base + chunk.offset, maxLength: remaining)
            }
            if written < 0 {
                finish()
                return
            }
            if written == 0 {
                return
            }
            let newOffset = chunk.offset + written
            if newOffset >= chunk.data.count {
                pending = nil
            } else {
                pending = (chunk.data, newOffset)
            }
        }
    }

    private func nextChunk() -> Data? {
        while sourceIndex < sources.count {
            switch sources[sourceIndex] {
            case .data(let blob):
                sourceIndex += 1
                return blob
            case .file(let url):
                if fileStream == nil {
                    guard let stream = InputStream(url: url) else {
                        sourceIndex += 1
                        continue
                    }
                    stream.open()
                    fileStream = stream
                }
                guard let stream = fileStream else {
                    sourceIndex += 1
                    continue
                }
                if stream.streamStatus == .error || !stream.hasBytesAvailable {
                    stream.close()
                    fileStream = nil
                    sourceIndex += 1
                    continue
                }
                var buf = [UInt8](repeating: 0, count: bufferSize)
                let bytesRead = stream.read(&buf, maxLength: buf.count)
                if bytesRead <= 0 {
                    stream.close()
                    fileStream = nil
                    sourceIndex += 1
                    continue
                }
                return Data(buf[0 ..< bytesRead])
            }
        }
        return nil
    }

    private func finish() {
        if done { return }
        done = true
        fileStream?.close()
        fileStream = nil
        output.remove(from: .current, forMode: .default)
        output.close()
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }
}

private final class ProducerThread: Thread {
    let producer: MultipartStreamProducer

    init(producer: MultipartStreamProducer) {
        self.producer = producer
        super.init()
        name = "DeclarativeRequests.MultipartProducer"
    }

    override func main() {
        producer.runOnThread()
    }
}
