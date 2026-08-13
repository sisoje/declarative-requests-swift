import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () throws -> any RequestBuildable) throws -> URLRequest {
        try RequestBlock {
            try builder()
            BaseURL(self)
        }.request
    }
}
