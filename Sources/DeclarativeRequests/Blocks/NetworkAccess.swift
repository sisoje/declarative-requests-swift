public enum NetworkAccess: CompositeNode {
    case NoCellular, NoExpensive, NoConstrained

    public var body: some BuilderNode {
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
