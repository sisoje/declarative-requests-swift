import Foundation

extension RequestBuilder {
    static func buildExpression(_ url: URL?) -> RequestTransformer {
        CustomTransformer {
            $0.baseURL = url
        }.transformer
    }
}
