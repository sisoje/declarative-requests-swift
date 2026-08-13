import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () throws -> any RequestBuildable) throws {
        self = try builder().request
    }
}
