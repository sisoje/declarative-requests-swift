import Foundation

public extension URL {
    func buildRequest(@RequestBuilder builder: () -> any RequestBuildable) throws -> URLRequest {
        try builder().base(self).request
    }
}
