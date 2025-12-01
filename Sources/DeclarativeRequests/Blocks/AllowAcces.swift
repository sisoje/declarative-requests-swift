public enum AllowAcces: RequestBuildable {
    case cellular(Bool)
    case expensiveNetwork(Bool)
    case constrainedNetwork(Bool)

    public var body: some RequestBuildable {
        switch self {
        case let .cellular(value):
            RequestState[\.request.allowsCellularAccess, value]
        case let .expensiveNetwork(value):
            RequestState[\.request.allowsExpensiveNetworkAccess, value]
        case let .constrainedNetwork(value):
            RequestState[\.request.allowsConstrainedNetworkAccess, value]
        }
    }
}
