import Foundation

extension URLRequest {
    static var initial: URLRequest {
        var res = URLRequest(url: URL(fileURLWithPath: ""))
        res.url = nil
        return res
    }

    init(@RequestBuilder builder: () -> RequestTransformer) throws {
        try self.init(transformer: builder())
    }

    init(transformer: RequestTransformer) throws {
        var state = RequestBuilderState()
        try transformer(&state)
        self = state.request
    }
}
