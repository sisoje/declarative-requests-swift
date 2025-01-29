import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> RequestBuilderNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
