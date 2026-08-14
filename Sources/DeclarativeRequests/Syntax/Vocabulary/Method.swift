public enum Method: RequestBuildable {
    case GET
    case HEAD
    case POST
    case PUT
    case DELETE
    case OPTIONS
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
        case .OPTIONS: "OPTIONS"
        case .PATCH: "PATCH"
        case .QUERY: "QUERY"
        case let .custom(method): method
        }
    }

    public var body: some RequestBuildable {
        RequestMutation(\.httpMethod, rawValue)
    }
}
