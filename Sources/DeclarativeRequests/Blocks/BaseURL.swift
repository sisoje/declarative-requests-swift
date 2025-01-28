import Foundation

struct BaseURL: RequestBuilderNode {
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
