import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> BuilderNode) throws {
        var state = RequestState()
        let transformer = builder().transformer
        try transformer(&state)
        self = state.request
    }
}
