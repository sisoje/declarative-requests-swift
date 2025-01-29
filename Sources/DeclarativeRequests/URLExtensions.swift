import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> RequestBuilderRootNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
