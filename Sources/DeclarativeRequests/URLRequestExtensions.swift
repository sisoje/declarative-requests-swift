import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> RequestBuildable) throws {
        var state = RequestState()
        let transformer = builder().transformRequest
        try transformer(&state)
        self = state.request
    }
}
