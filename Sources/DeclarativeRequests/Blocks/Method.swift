public enum Method: String, RequestBuilderCompositeNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

    public var body: some RequestBuilderNode {
        RequestBuilderState[\.request.httpMethod, rawValue]
    }

    public static func custom(_ method: String) -> some RequestBuilderNode {
        RequestBuilderState[\.request.httpMethod, method]
    }
}
