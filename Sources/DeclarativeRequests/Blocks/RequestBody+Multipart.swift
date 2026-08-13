import Foundation

public extension RequestBody {
    static func multipart(
        boundary: String? = nil,
        @MultipartBuilder _ parts: () -> [MultipartPart]
    ) -> some RequestBuildable {
        let parts = parts()
        let boundary = boundary ?? "Boundary-\(UUID().uuidString)"
        return RequestBlock { state in
            state.request.httpBody = try encode(parts: parts, boundary: boundary)
            state.request.setValue(contentType(boundary: boundary), forHTTPHeaderField: Header.contentType.rawValue)
        }
    }
}

public enum MultipartPart {
    case field(name: String, value: String)
    case data(name: String, filename: String, data: Data, type: String = "application/octet-stream")
    case file(name: String, fileURL: URL, type: String = "application/octet-stream", filename: String? = nil)
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

private func encode(parts: [MultipartPart], boundary: String) throws -> Data {
    var body = Data()
    for part in parts {
        body.append(Data(partHeader(part, boundary: boundary).utf8))
        switch part {
        case let .field(_, value):
            body.append(Data(value.utf8))
        case let .data(_, _, payload, _):
            body.append(payload)
        case let .file(_, url, _, _):
            do {
                try body.append(Data(contentsOf: url))
            } catch {
                throw DeclarativeRequestsError.badMultipart(
                    reason: "Could not read \(url.lastPathComponent): \(error.localizedDescription)"
                )
            }
        }
        body.append(Data("\r\n".utf8))
    }
    body.append(Data("--\(boundary)--\r\n".utf8))
    return body
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

private func fileHeader(name: String, filename: String, type: String, boundary: String) -> String {
    "--\(boundary)\r\n" +
        "Content-Disposition: form-data; name=\"\(quoteParam(name))\"; filename=\"\(quoteParam(filename))\"\r\n" +
        "Content-Type: \(type)\r\n\r\n"
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

