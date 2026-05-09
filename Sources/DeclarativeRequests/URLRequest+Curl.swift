import Foundation

public extension URLRequest {
    /// A copy-pasteable `curl` command equivalent of this request.
    ///
    /// Useful for debugging, reproducing failures from a terminal, and pasting into
    /// bug reports. The output is single-quoted so values containing shell
    /// metacharacters survive a copy-paste; embedded single quotes are escaped via
    /// the standard `'\''` trick.
    ///
    /// ```swift
    /// let request = try URLRequest {
    ///     Method.POST
    ///     BaseURL("https://api.example.com")
    ///     Endpoint("/login")
    ///     Header.accept.setValue("application/json")
    ///     Body("{\"user\":\"alice\"}", type: .JSON)
    /// }
    /// print(request.curlCommand)
    /// // curl -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' \
    /// //   --data-binary '{"user":"alice"}' 'https://api.example.com/login'
    /// ```
    ///
    /// `GET` is the implicit default and is omitted from the output. Bodies that
    /// aren't valid UTF-8 are noted as a comment with the byte count rather than
    /// dumped raw.
    var curlCommand: String {
        var parts: [String] = ["curl"]

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
