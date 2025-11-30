import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
        try URLRequest {
            builder()
            self
        }
    }
}
