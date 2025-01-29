public enum Method: String, RequestBuilderNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

    public var body: some RequestBuilderRootNode {
        RequestBuilderState[\.request.httpMethod, rawValue]
    }

    public static func custom(_ method: String) -> some RequestBuilderRootNode {
        RequestBuilderState[\.request.httpMethod, method]
    }
}
