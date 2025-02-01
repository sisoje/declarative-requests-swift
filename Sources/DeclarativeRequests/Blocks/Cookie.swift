public struct Cookie: CompositeNode {
    private let items: [(String, String)]

    public init(_ name: String, _ value: String) {
        items = [(name, value)]
    }

    public init(_ cookies: [(String, String)]) {
        items = cookies
    }

    public init(_ cookies: [String: String]) {
        items = cookies.map { ($0.key, $0.value) }
    }

    public init(object: Any) {
        let queryItems = Array(queryItemsReflecting: object)
        items = queryItems.map { ($0.name, $0.value ?? "") }
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
