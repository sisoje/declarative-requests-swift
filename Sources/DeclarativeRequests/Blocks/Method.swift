public enum Method: String, RequestBuildable {
    case GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

    public var body: some RequestBuildable {
        RequestState[\.request.httpMethod, rawValue]
    }

    public static func custom(_ method: String) -> some RequestBuildable {
        RequestState[\.request.httpMethod, method]
    }
}
