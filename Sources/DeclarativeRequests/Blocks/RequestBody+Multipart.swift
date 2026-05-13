import Foundation

public extension RequestBody {
    enum MultipartStrategy {
        case inMemory
        case streamed(bufferSize: Int = 64 * 1024)
    }

    static func multipart(
        boundary: String? = nil,
        strategy: MultipartStrategy = .inMemory,
        @MultipartBuilder _ parts: () -> [MultipartPart]
    ) -> some RequestBuildable {
        let parts = parts()
        let boundary = boundary ?? "Boundary-\(UUID().uuidString)"
        return RequestBlock { state in
            let sources = try encode(parts: parts, boundary: boundary)
            switch strategy {
            case .inMemory:
                try applyInMemory(sources: sources, boundary: boundary, state: state)
            case let .streamed(bufferSize):
                try applyStreamed(sources: sources, boundary: boundary, bufferSize: bufferSize, state: state)
            }
        }
    }
}

public enum MultipartPart {
    case field(name: String, value: String)
    case data(name: String, filename: String, data: Data, type: MIMEType = .octetStream)
    case file(name: String, fileURL: URL, type: MIMEType = .octetStream, filename: String? = nil)
}

@_documentation(visibility: internal)
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

private enum ByteSource {
    case data(Data)
    case file(URL, size: Int64)

    var count: Int64 {
        switch self {
        case let .data(d): Int64(d.count)
        case let .file(_, n): n
        }
    }
}

private func encode(parts: [MultipartPart], boundary: String) throws -> [ByteSource] {
    var sources: [ByteSource] = []
    for part in parts {
        sources.append(.data(Data(partHeader(part, boundary: boundary).utf8)))
        switch part {
        case let .field(_, value):
            sources.append(.data(Data(value.utf8)))
        case let .data(_, _, payload, _):
            sources.append(.data(payload))
        case let .file(_, url, _, _):
            sources.append(.file(url, size: try fileSize(url)))
        }
        sources.append(.data(Data("\r\n".utf8)))
    }
    sources.append(.data(Data("--\(boundary)--\r\n".utf8)))
    return sources
}

private func partHeader(_ part: MultipartPart, boundary: String) -> String {
    switch part {
    case let .field(name, _):
        "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(quoteParam(name))\"\r\n\r\n"
    case let .data(name, filename, _, type):
        fileHeader(name: name, filename: filename, type: type, boundary: boundary)
    case let .file(name, url, type, filename):
        fileHeader(name: name, filename: filename ?? url.lastPathComponent, type: type, boundary: boundary)
    }
}

private func fileHeader(name: String, filename: String, type: MIMEType, boundary: String) -> String {
    "--\(boundary)\r\n" +
        "Content-Disposition: form-data; name=\"\(quoteParam(name))\"; filename=\"\(quoteParam(filename))\"\r\n" +
        "Content-Type: \(type.rawValue)\r\n\r\n"
}

private func quoteParam(_ s: String) -> String {
    var out = ""
    out.unicodeScalars.reserveCapacity(s.unicodeScalars.count)
    for scalar in s.unicodeScalars {
        switch scalar {
        case "\\": out.append("\\\\")
        case "\"": out.append("\\\"")
        case "\r", "\n": continue
        default: out.unicodeScalars.append(scalar)
        }
    }
    return out
}

private func contentType(boundary: String) -> String {
    needsQuoting(boundary)
        ? "multipart/form-data; boundary=\"\(boundary)\""
        : "multipart/form-data; boundary=\(boundary)"
}

private func needsQuoting(_ token: String) -> Bool {
    guard !token.isEmpty else { return true }
    let tokenChars = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'+_-")
    return !token.allSatisfy { tokenChars.contains($0) }
}

private func fileSize(_ url: URL) throws -> Int64 {
    let attrs: [FileAttributeKey: Any]
    do {
        attrs = try FileManager.default.attributesOfItem(atPath: url.path)
    } catch {
        throw DeclarativeRequestsError.badMultipart(
            reason: "Could not stat \(url.lastPathComponent): \(error.localizedDescription)"
        )
    }
    guard let size = (attrs[.size] as? NSNumber)?.int64Value else {
        throw DeclarativeRequestsError.badMultipart(
            reason: "File \(url.lastPathComponent) has no .size attribute"
        )
    }
    return size
}

private func applyInMemory(sources: [ByteSource], boundary: String, state: RequestState) throws {
    var body = Data()
    body.reserveCapacity(Int(sources.map(\.count).reduce(0, +)))
    for src in sources {
        switch src {
        case let .data(d):
            body.append(d)
        case let .file(url, _):
            do {
                body.append(try Data(contentsOf: url))
            } catch {
                throw DeclarativeRequestsError.badMultipart(
                    reason: "Could not read \(url.lastPathComponent): \(error.localizedDescription)"
                )
            }
        }
    }
    state.request.httpBody = body
    state.request.setValue(contentType(boundary: boundary), forHTTPHeaderField: Header.contentType.rawValue)
}

private func applyStreamed(sources: [ByteSource], boundary: String, bufferSize: Int, state: RequestState) throws {
    let totalLength = sources.map(\.count).reduce(0, +)

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
    state.request.setValue(contentType(boundary: boundary), forHTTPHeaderField: Header.contentType.rawValue)
    state.request.setValue("\(totalLength)", forHTTPHeaderField: "Content-Length")

    MultipartStreamProducer(sources: sources, output: output, bufferSize: bufferSize).start()
}

private final class MultipartStreamProducer: NSObject, StreamDelegate {
    private let bufferSize: Int
    private let output: OutputStream
    private var sources: [ByteSource]
    private var sourceIndex: Int = 0
    private var fileStream: InputStream?
    private var pending: (data: Data, offset: Int)?
    private var thread: Thread?
    private var done = false

    init(sources: [ByteSource], output: OutputStream, bufferSize: Int) {
        self.bufferSize = bufferSize
        self.output = output
        self.sources = sources
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
            case let .data(blob):
                sourceIndex += 1
                return blob
            case let .file(url, _):
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
