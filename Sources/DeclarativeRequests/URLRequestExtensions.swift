import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> RequestBuildable) throws {
        var state = RequestState()
        let transformRequest = builder().transformRequest
        try transformRequest(&state)
        self = state.request
    }
}
