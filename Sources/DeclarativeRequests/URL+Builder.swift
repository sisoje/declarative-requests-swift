import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
        let built = builder()
        return try RequestBuilderGroup {
            built
            BaseURL(self)
        }.request
    }
}
