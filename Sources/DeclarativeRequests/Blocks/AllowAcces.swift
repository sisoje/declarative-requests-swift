public enum AllowAcces: RequestBuildable {
    case cellular(Bool)
    case expensiveNetwork(Bool)
    case constrainedNetwork(Bool)
    case ultraConstrainedNetwork(Bool)

    public var body: some RequestBuildable {
        switch self {
        case let .cellular(value):
            RequestState[\.request.allowsCellularAccess, value]
        case let .expensiveNetwork(value):
            RequestState[\.request.allowsExpensiveNetworkAccess, value]
        case let .constrainedNetwork(value):
            RequestState[\.request.allowsConstrainedNetworkAccess, value]
        case let .ultraConstrainedNetwork(value):
            if #available(macOS 26.1, iOS 26.1, watchOS 26.1, tvOS 26.1, *) {
                RequestState[\.request.allowsUltraConstrainedNetworkAccess, value]
            }
        }
    }
}
