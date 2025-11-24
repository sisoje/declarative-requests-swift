public enum NetworkAccess: RequestBuildable {
    case NoCellular, NoExpensive, NoConstrained

    public var body: some RequestBuildable {
        switch self {
        case .NoCellular:
            RequestState[\.request.allowsCellularAccess, false]
        case .NoExpensive:
            RequestState[\.request.allowsExpensiveNetworkAccess, false]
        case .NoConstrained:
            RequestState[\.request.allowsConstrainedNetworkAccess, false]
        }
    }
}
