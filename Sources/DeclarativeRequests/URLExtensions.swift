import Foundation

extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        try URLRequest {
            builder
            BaseURL(url: self)
        }
    }
}
