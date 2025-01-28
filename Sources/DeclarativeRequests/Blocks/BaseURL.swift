import Foundation

public struct BaseURL: RequestBuilderModifyNode {
    let url: URL?
    func modify(state: inout RequestBuilderState) {
        state.baseURL = url
    }
}

extension RequestBuilder {
    static func buildExpression(_ url: URL?) -> RequestTransformer {
        BaseURL(url: url).transformer
    }
}
