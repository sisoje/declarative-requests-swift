import Foundation

extension RequestBuilder {
    static func buildExpression(_ data: Data?) -> RequestTransformer {
        CustomTransformer {
            $0.request.httpBody = data
        }.transformer
    }
}
