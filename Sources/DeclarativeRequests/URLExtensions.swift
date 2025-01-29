import Foundation

public extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestBuilderNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
