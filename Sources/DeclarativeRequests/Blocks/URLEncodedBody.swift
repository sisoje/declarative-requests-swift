import Foundation

extension Data {
    static func httpBody(_ items: [URLQueryItem]) -> Data? {
        var components = URLComponents()
        components.queryItems = items
        return components.percentEncodedQuery?.data(using: .utf8)
    }
}

extension Array where Element == URLQueryItem {
    init(queryItemsReflecting object: Any) {
        self = Mirror(reflecting: object).children
            .compactMap { child in
                guard let name = child.label else { return nil }

                if let num = child.value as? NSNumber {
                    return URLQueryItem(name: name, value: num.description)
                }

                if let str = child.value as? String {
                    return URLQueryItem(name: name, value: str)
                }

                return nil
            }
    }
}

public struct URLEncodedBody: CompositeNode {
    public init(_ name: String, _ value: String?) {
        items = [URLQueryItem(name: name, value: value)]
    }

    public init(_ params: [(String, String?)]) {
        items = params.map(URLQueryItem.init)
    }

    public init(_ params: [String: String?]) {
        items = params.map(URLQueryItem.init)
    }

    public init(_ items: [URLQueryItem]) {
        self.items = items
    }

    public init(object: Any) {
        items = Array(queryItemsReflecting: object)
    }

    let items: [URLQueryItem]

    public var body: some BuilderNode {
        RequestBlock { state in
            state.encodedBodyItems += items
            state.request.httpBody = .httpBody(state.encodedBodyItems)
            assert(state.request.httpBody != nil)
        }
    }
}
