public enum Method: RequestBuildable {
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case CONNECT
    case OPTIONS
    case TRACE
    case PATCH
    case QUERY
    case custom(String)

    public var rawValue: String {
        switch self {
        case .GET: "GET"
        case .HEAD: "HEAD"
        case .POST: "POST"
        case .PUT: "PUT"
        case .DELETE: "DELETE"
        case .CONNECT: "CONNECT"
        case .OPTIONS: "OPTIONS"
        case .TRACE: "TRACE"
        case .PATCH: "PATCH"
        case .QUERY: "QUERY"
        case let .custom(method): method
        }
    }

    public var body: some RequestBuildable {
        RequestMutation(\.httpMethod, rawValue)
    }
}
