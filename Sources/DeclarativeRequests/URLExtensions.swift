import Foundation

public extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> RequestBuilderRootNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
