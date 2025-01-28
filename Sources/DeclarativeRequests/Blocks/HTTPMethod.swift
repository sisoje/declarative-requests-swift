public enum HTTPMethod: String, RequestBuilderModifyNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH
    func modify(state: inout RequestBuilderState) {
        state.request.httpMethod = rawValue
    }

    static func custom(_ method: String) -> RequestBuilderNode {
        CustomTransformer {
            $0.request.httpMethod = method
        }
    }
}
