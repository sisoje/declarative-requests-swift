import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> any RequestBuildable) throws {
        self = try RequestBlock(builder: builder).request
    }
}
