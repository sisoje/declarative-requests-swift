import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
        try RequestBlock {
            builder()
            BaseURL(self)
        }.request
    }
}
