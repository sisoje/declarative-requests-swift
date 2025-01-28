import Foundation

public extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestTransformer) throws -> URLRequest {
        try URLRequest {
            builder
            BaseURL(self)
        }
    }
}
