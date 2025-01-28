import Foundation

extension URLRequest {
    init(@RequestBuilder builder: () -> RequestTransformer) throws {
        var state = RequestBuilderState()
        let transformer = builder()
        try transformer(&state)
        self = state.request
    }
}
