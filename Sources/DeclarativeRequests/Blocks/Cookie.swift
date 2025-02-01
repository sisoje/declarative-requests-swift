import Foundation

public struct Cookie: CompositeNode {
    private let items: [(String, String)]
    
    public init(_ name: String, _ value: String) {
        self.items = [(name, value)]
    }
    
    public init(_ cookies: [(String, String)]) {
        self.items = cookies.map { ($0.0, $0.1) }
    }
    
    public init(_ cookies: [String: String]) {
        self.items = cookies.map { ($0.key, $0.value) }
    }
    
    public init(object: Any) {
        let queryItems = Array(queryItemsReflecting: object)
        self.items = queryItems.map { ($0.name, $0.value ?? "") }
    }
    
    public var body: some BuilderNode {
        RequestBlock { state in
            guard !items.isEmpty else { return }
            
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