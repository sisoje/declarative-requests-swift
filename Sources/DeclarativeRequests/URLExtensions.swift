import Foundation

extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        let transformer = RequestTransformerUtils.merge(builder(), BaseURL(url: self).transformer)
        return try URLRequest(transformer: transformer)
    }
}
