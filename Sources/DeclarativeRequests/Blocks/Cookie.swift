import Foundation

import Foundation

public struct Cookie: CompositeNode {
    private let items: [(String, String)]

    public init(_ name: String, _ value: String) {
        items = [(Self.encodeCookie(name), Self.encodeCookie(value))]
    }

    public init(_ cookies: [(String, String)]) {
        items = cookies
            .map {
                (Self.encodeCookie($0.0), Self.encodeCookie($0.1))
            }
    }

    public init(_ cookies: [String: String]) {
        items = cookies
            .map {
                (Self.encodeCookie($0.key), Self.encodeCookie($0.value))
            }
    }

    public init(object: Any) {
        let queryItems = Array(queryItemsReflecting: object)
        items = queryItems
            .map {
                (Self.encodeCookie($0.name), Self.encodeCookie($0.value ?? ""))
            }
    }

    private static func encodeCookie(_ value: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "!#$%&'()*+-./:<=>?@[]^_`{|}~"))

        return value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }

    private static func parseCookieString(_ cookieString: String) -> [(String, String)] {
        return cookieString
            .split(separator: ";")
            .compactMap { pair -> (String, String)? in
                let parts = pair.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { return nil }

                let name = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)

                guard !name.isEmpty, !value.isEmpty else { return nil }

                return (name, value)
            }
    }

    private static func mergeCookies(_ existing: [(String, String)], with new: [(String, String)]) -> [(String, String)] {
        var cookieDict: [String: String] = [:]

        for (name, value) in existing {
            cookieDict[encodeCookie(name)] = encodeCookie(value)
        }

        for (name, value) in new {
            cookieDict[encodeCookie(name)] = encodeCookie(value)
        }

        return cookieDict
            .map {
                ($0.key, $0.value)
            }
    }

    public var body: some BuilderNode {
        RequestBlock { request in
            guard !items.isEmpty else { return }

            let existingCookies = request.request.value(forHTTPHeaderField: "Cookie")
                .map(Self.parseCookieString) ?? []

            let mergedCookies = Self.mergeCookies(existingCookies, with: items)

            let cookieString = mergedCookies
                .map { "\($0.0)=\($0.1)" }
                .joined(separator: "; ")

            request.request.setValue(cookieString, forHTTPHeaderField: "Cookie")
        }
    }
}
