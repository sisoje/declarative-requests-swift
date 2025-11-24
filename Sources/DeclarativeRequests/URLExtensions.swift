import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> RequestBuildable) throws -> URLRequest {
        try URLRequest {
            builder()
            self
        }
    }
}
