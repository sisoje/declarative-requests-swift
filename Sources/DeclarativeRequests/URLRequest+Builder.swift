import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: @escaping () -> any RequestBuildable) throws {
        self = try RequestBuilderGroup(builder: builder).request
    }
}
