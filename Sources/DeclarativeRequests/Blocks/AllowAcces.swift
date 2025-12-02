public enum AllowAcces: RequestBuildable {
    case cellular(Bool)
    case expensiveNetwork(Bool)
    case constrainedNetwork(Bool)
    case ultraConstrainedNetwork(Bool)

    public var body: some RequestBuildable {
        switch self {
        case .cellular(let value):
            RequestState[\.request.allowsCellularAccess, value]
        case .expensiveNetwork(let value):
            RequestState[\.request.allowsExpensiveNetworkAccess, value]
        case .constrainedNetwork(let value):
            RequestState[\.request.allowsConstrainedNetworkAccess, value]
        case .ultraConstrainedNetwork(let value):
            if #available(macOS 26.1, iOS 26.1, watchOS 26.1, tvOS 26.1, *) {
                RequestState[\.request.allowsUltraConstrainedNetworkAccess, value]
            }
        }
    }
}
