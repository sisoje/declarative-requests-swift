import Foundation

/// Builds a streaming `multipart/form-data` body suitable for very large uploads.
///
/// Unlike ``MultipartBody``, which assembles the entire payload in memory,
/// `StreamedMultipartBody` reads ``MultipartPart/file(name:fileURL:type:filename:)``
/// parts from disk on demand as the request is sent. Memory use stays bounded
/// to roughly `bufferSize` regardless of how big the files are, so payloads in
/// the hundreds of gigabytes (or terabytes) are practical.
///
/// ```swift
/// let request = try URLRequest {
///     Method.POST
///     BaseURL("https://uploads.example.com")
///     Endpoint("/videos")
///     StreamedMultipartBody {
///         MultipartPart.field(name: "title", value: "Vacation 2026")
///         MultipartPart.file(name: "video", fileURL: hugeVideoURL, type: .MP4)
///     }
/// }
/// let (data, response) = try await URLSession.shared.data(for: request)
/// ```
///
/// ## How it works
///
/// At build time:
/// 1. Each part's contribution to the body is measured. For
///    ``MultipartPart/file(name:fileURL:type:filename:)`` parts, the size is
///    read from the filesystem. The total is set as `Content-Length`.
/// 2. A bound `InputStream`/`OutputStream` pair is created via
///    `Stream.getBoundStreams(withBufferSize:inputStream:outputStream:)`.
/// 3. The input stream is attached to the request as `httpBodyStream`. The
///    output stream is wired to a producer that runs on a dedicated thread,
///    streaming bytes through as `URLSession` reads them.
/// 4. The producer reads file parts in `bufferSize`-sized chunks. Memory use
///    is bounded by the buffer regardless of file size.
///
/// ## Memory characteristics
///
/// - ``MultipartPart/field(name:value:)``: in memory (typically tiny).
/// - ``MultipartPart/data(name:filename:data:type:)``: in memory (the `Data` blob).
/// - ``MultipartPart/file(name:fileURL:type:filename:)``: read from disk in
///   `bufferSize` chunks; never fully held in memory.
///
/// To stream a non-file source, write it to a temp file first and pass that as
/// `.file`.
///
/// ## Limitations
///
/// - **No automatic retry.** The underlying body stream is single-use. If
///   `URLSession` needs a fresh body (e.g. on an authentication challenge), it
///   has no way to obtain one. For retry-resilient uploads use a custom
///   `URLSessionTaskDelegate` and `urlSession(_:task:needNewBodyStream:)`.
/// - **Don't modify source files mid-upload.** `Content-Length` is computed
///   before the upload starts. If a file shrinks while the upload is in
///   progress, the upload will be truncated; if it grows, the extra bytes are
///   ignored.
/// - **Build-then-discard leaks the producer thread.** If you build a request
///   but never send it, the producer thread will idle holding the streams. In
///   practice this is rare; if you build speculatively, drop references to
///   the request once you decide not to use it so the system can tear it down
///   on error.
public struct StreamedMultipartBody: RequestBuildable, Sendable {
    let parts: [MultipartPart]
    let boundary: String
    let bufferSize: Int

    /// Create a `StreamedMultipartBody` from a builder closure.
    ///
    /// - Parameters:
    ///   - boundary: The multipart boundary token. Defaults to a random
    ///     `Boundary-<UUID>` value.
    ///   - bufferSize: The chunk size used for both the bound stream pair and
    ///     for reading from disk. Defaults to 64 KB.
    ///   - parts: A `@MultipartBuilder` closure that produces the parts.
    public init(
        boundary: String? = nil,
        bufferSize: Int = 64 * 1024,
        @MultipartBuilder _ parts: () -> [MultipartPart]
    ) {
        self.parts = parts()
        self.boundary = boundary ?? "Boundary-\(UUID().uuidString)"
        self.bufferSize = bufferSize
    }

    /// Create a `StreamedMultipartBody` from an explicit `[MultipartPart]` array.
    ///
    /// - Parameters:
    ///   - parts: The parts to include.
    ///   - boundary: The multipart boundary token. Defaults to a random
    ///     `Boundary-<UUID>` value.
    ///   - bufferSize: The chunk size used for both the bound stream pair and
    ///     for reading from disk. Defaults to 64 KB.
    public init(_ parts: [MultipartPart], boundary: String? = nil, bufferSize: Int = 64 * 1024) {
        self.parts = parts
        self.boundary = boundary ?? "Boundary-\(UUID().uuidString)"
        self.bufferSize = bufferSize
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
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
                forHTTPHeaderField: Header.contentType.rawValue
            )
            state.request.setValue("\(length)", forHTTPHeaderField: "Content-Length")

            MultipartStreamProducer(
                parts: parts,
                boundary: boundary,
                output: output,
                bufferSize: bufferSize
            ).start()
        }
    }
}

// MARK: - Content-Length computation

enum MultipartLength {
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

// MARK: - Producer

/// Drives the output side of a bound stream pair, feeding multipart bytes as
/// `URLSession` reads them. Runs on a dedicated thread with its own runloop;
/// shuts down automatically when the body is exhausted or the consumer
/// disconnects.
final class MultipartStreamProducer: NSObject, StreamDelegate, @unchecked Sendable {
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
        self.sources = Self.buildSources(parts: parts, boundary: boundary)
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
        let thread = Thread { [self] in
            self.runOnThread()
        }
        thread.name = "DeclarativeRequests.MultipartProducer"
        self.thread = thread
        thread.start()
    }

    private func runOnThread() {
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
            self.feed()
        case .errorOccurred, .endEncountered:
            self.finish()
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
                return Data(buf[0..<bytesRead])
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
