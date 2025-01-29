import Foundation

public extension URL {
    func buildRequest(@RequestBuilder _ builder: () -> BuilderNode) throws -> URLRequest {
        try URLRequest {
            builder()
            BaseURL(self)
        }
    }
}
