import Foundation

public struct Cookie: CompositeNode {
    private let items: [String: String]

    public init(_ name: String, _ value: String) {
        items = [name: value]
    }

    public init(_ cookies: [String: String]) {
        items = cookies
    }

    public init(object: Any) {
        items = Dictionary(reflecting: object)
    }

    public var body: some BuilderNode {
        RequestBlock { state in
            for (name, value) in items {
                state.cookies[name] = value
            }

            let cookieString = state.cookies
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "; ")

            if !cookieString.isEmpty {
                state.request.setValue(cookieString, forHTTPHeaderField: "Cookie")
            }
        }
    }
}
