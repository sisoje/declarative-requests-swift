import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: @escaping () -> any RequestBuildable) throws -> URLRequest {
        try RequestBuilderGroup {
            builder()
            BaseURL(self)
        }.request
    }
}
