import Foundation

struct QueryParams: RequestBuilderModifyNode {
    let params: [String: String?]
    func modify(state: inout RequestBuilderState) {
        let newItems = params.map(URLQueryItem.init)
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + newItems
    }
}

extension RequestBuilder {
    static func buildExpression(_ item: URLQueryItem) -> RequestTransformer {
        QueryParams(params: ([item.name: item.value])).transformer
    }
    
    static func buildExpression<T: Collection>(_ items: T) -> RequestTransformer where T.Element == URLQueryItem {
        buildArray(items.map { item in
            buildExpression(item)
        })
    }
}
