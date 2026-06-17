public enum Method: String, RequestBuildable {
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case CONNECT
    case OPTIONS
    case TRACE
    case PATCH

    public var body: some RequestBuildable {
        RequestMutation[\.httpMethod, rawValue]
    }

    public static func custom(_ method: String) -> some RequestBuildable {
        RequestMutation[\.httpMethod, method]
    }
}
