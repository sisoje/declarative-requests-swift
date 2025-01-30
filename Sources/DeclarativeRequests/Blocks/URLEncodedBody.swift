import Foundation

enum DeclarativeNetworkingError: Error {
    case percentEncodingFailed
}

extension Array where Element == URLQueryItem {
    init(queryItemsReflecting object: Any) {
        self = Mirror(reflecting: object).children.compactMap { child in
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
    let contentType = "application/x-www-form-urlencoded"
    
    public init(_ name: String, _ value: String?) {
        self.items = [URLQueryItem(name: name, value: value)]
    }

    public init(_ params: [(String, String?)]) {
        self.items = params.map(URLQueryItem.init)
    }
    
    public init(_ params: [String: String?]) {
        self.items = params.map(URLQueryItem.init)
    }
    
    public init(_ items: [URLQueryItem]) {
        self.items = items
    }

    public init(object: Any) {
        self.items = Array(queryItemsReflecting: object)
    }
    
    let items: [URLQueryItem]
    
    public var body: some BuilderNode {
        RequestBlock { state in
            state.encodedBodyItems += items
            var components = URLComponents()
            components.queryItems = state.encodedBodyItems
            if let data = components.percentEncodedQuery?.data(using: .utf8) {
                state.request.httpBody = data
            } else {
                throw DeclarativeNetworkingError.percentEncodingFailed
            }
        }
        Header.contentType.addValue(contentType)
    }
}
