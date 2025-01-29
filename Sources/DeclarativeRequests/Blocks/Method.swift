public enum Method: String, CompositeNode {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

    public var body: some BuilderNode {
        RequestState[\.request.httpMethod, rawValue]
    }

    public static func custom(_ method: String) -> some BuilderNode {
        RequestState[\.request.httpMethod, method]
    }
}
