import Foundation

public extension URLRequest {
    init(@RequestBuilder builder: () -> RequestBuilderNode) throws {
        var state = RequestBuilderState()
        let transformer = builder().transformer
        try transformer(&state)
        self = state.request
    }
}
