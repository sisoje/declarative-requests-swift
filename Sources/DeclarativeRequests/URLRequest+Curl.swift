import Foundation

public extension URLRequest {
    var curlCommand: String {
        var parts = ["curl"]

        if let method = httpMethod, method.uppercased() != "GET" {
            parts.append("-X \(method)")
        }

        let headers = (allHTTPHeaderFields ?? [:]).sorted { $0.key < $1.key }
        for (name, value) in headers {
            parts.append("-H " + Self.quote("\(name): \(value)"))
        }

        if let body = httpBody {
            if let text = String(data: body, encoding: .utf8) {
                parts.append("--data-binary " + Self.quote(text))
            } else {
                parts.append("# binary body of \(body.count) bytes omitted")
            }
        }

        if let url = url?.absoluteString {
            parts.append(Self.quote(url))
        }

        return parts.joined(separator: " ")
    }

    private static func quote(_ string: String) -> String {
        "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
