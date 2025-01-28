import Foundation

struct PostData: RequestBuilderNode {
    let data: Data?
    
    func modify(state: inout RequestBuilderState) throws {
        state.request.httpBody = data
    }
}

extension RequestBuilder {
    static func buildExpression(_ data: Data?) -> RequestTransformer {
        PostData(data: data).transformer
    }
}
