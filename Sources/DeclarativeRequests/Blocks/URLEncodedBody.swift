import Foundation

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

    public init(_ value: some Encodable) {
        let data = try? JSONEncoder().encode(value)
        guard let dict = try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String: Any],
              dict.values.allSatisfy({ $0 is String || $0 is NSNumber }) else {
            self.items = []
            return
        }
        self.items = dict.map { URLQueryItem(name: $0, value: String(describing: $1)) }
    }
    
    let items: [URLQueryItem]
    
    private func parseExistingFormData(_ request: URLRequest) -> [URLQueryItem]? {
        guard let contentType = request.value(forHTTPHeaderField: "Content-Type"),
              contentType.contains(contentType),
              let existingData = request.httpBody,
              let query = String(data: existingData, encoding: .utf8) else {
            return nil
        }
        
        return URLComponents(string: "?" + query)?.queryItems
    }
    
    public var body: some BuilderNode {
        RootNode { state in
            var components = URLComponents()
            let existingItems = parseExistingFormData(state.request) ?? []
            components.queryItems = existingItems + items
            
            state.request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
            state.request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
    }
}
