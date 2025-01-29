import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> BuilderNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
