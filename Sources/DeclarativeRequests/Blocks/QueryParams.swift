import Foundation

public struct QueryParams: RequestBuilderModifyNode {
    public init(_ params: [String: String?]) {
        self.params = params
    }

    let params: [String: String?]
    func modify(state: inout RequestBuilderState) {
        let newItems = params.map(URLQueryItem.init)
        let oldItems = state.pathComponents.queryItems ?? []
        state.pathComponents.queryItems = oldItems + newItems
    }
}
