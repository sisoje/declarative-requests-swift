import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> any RequestBuildable) throws {
        var state = RequestState()
        let transformRequest = builder().transform
        try transformRequest(&state)
        self = state.request
    }
}
