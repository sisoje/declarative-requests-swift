public enum DisallowAccess: CompositeNode {
    case Cellular, Expensive, Constrained

    public var body: some BuilderNode {
        RequestBlock {
            switch self {
            case .Cellular:
                RequestState[\.request.allowsCellularAccess, false]
            case .Expensive:
                RequestState[\.request.allowsExpensiveNetworkAccess, false]
            case .Constrained:
                RequestState[\.request.allowsConstrainedNetworkAccess, false]
            }
        }
    }
}
