import Foundation

public struct Cookie: CompositeNode {
    private let items: [(String, String)]

    public init(_ name: String, _ value: String) {
        items = [(Self.validateName(name), Self.encodeValue(value))]
    }

    public init(_ cookies: [(String, String)]) {
        items = cookies.map { (Self.validateName($0.0), Self.encodeValue($0.1)) }
    }

    public init(_ cookies: [String: String]) {
        items = cookies.map { (Self.validateName($0.key), Self.encodeValue($0.value)) }
    }

    public init(object: Any) {
        let queryItems = Array(queryItemsReflecting: object)
        items = queryItems.map { (Self.validateName($0.name), Self.encodeValue($0.value ?? "")) }
    }

    private static func validateName(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: "()<>@,;:\\\"/[]?={} \t")
            .union(CharacterSet.controlCharacters)

        let validName = name.components(separatedBy: invalidChars).joined()

        guard !validName.isEmpty else {
            return "invalid_cookie_name"
        }

        return validName
    }

    private static func encodeValue(_ value: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "!#$%&'()*+-./:<=>?@[]^_`{|}~"))

        return value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }

    public var body: some BuilderNode {
        RequestBlock { request in
            let newCookieString = items
                .map { "\($0.0)=\($0.1)" }
                .joined(separator: "; ")

            if !newCookieString.isEmpty {
                let finalCookieString = request.request.value(forHTTPHeaderField: "Cookie")
                    .map { "\($0); \(newCookieString)" }
                    ?? newCookieString

                request.request.setValue(finalCookieString, forHTTPHeaderField: "Cookie")
            }
        }
    }
}
