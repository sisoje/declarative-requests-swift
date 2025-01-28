import Foundation

extension URLRequest {
    static var initial: URLRequest {
        var res = URLRequest(url: URL(fileURLWithPath: ""))
        res.url = nil
        return res
    }

    init(@RequestBuilder builder: () -> RequestTransformer) throws {
        var state = RequestBuilderState()
        let transformer = builder()
        try transformer(&state)
        self = state.request
    }
}
