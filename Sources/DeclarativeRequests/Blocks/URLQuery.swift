import Foundation

public struct URLQuery: RequestBuilderModifyNode {
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

    let items: [URLQueryItem]
    func modify(state: inout RequestBuilderState) {
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + items
    }
}
