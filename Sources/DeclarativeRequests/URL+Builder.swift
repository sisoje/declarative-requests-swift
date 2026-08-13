import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () throws -> any RequestBuildable) throws -> URLRequest {
        let built = try builder()
        return try RequestBlock {
            built
            BaseURL(self)
        }.request
    }
}
