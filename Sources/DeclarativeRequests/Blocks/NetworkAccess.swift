public struct NetworkAccess: CompositeNode {
    let allowCellular: Bool
    let allowExpensive: Bool
    let allowConstrained: Bool

    public init(cellular: Bool = true, expensive: Bool = true, constrained: Bool = true) {
        allowCellular = cellular
        allowExpensive = expensive
        allowConstrained = constrained
    }

    public func allowCellular(_ allow: Bool) -> NetworkAccess {
        NetworkAccess(cellular: allow, expensive: allowExpensive, constrained: allowConstrained)
    }

    public func allowExpensive(_ allow: Bool) -> NetworkAccess {
        NetworkAccess(cellular: allowCellular, expensive: allow, constrained: allowConstrained)
    }

    public func allowConstrained(_ allow: Bool) -> NetworkAccess {
        NetworkAccess(cellular: allowCellular, expensive: allowExpensive, constrained: allow)
    }

    public static var wifiOnly: Self {
        NetworkAccess(cellular: false, expensive: false, constrained: true)
    }

    public static var unrestricted: Self {
        NetworkAccess(cellular: true, expensive: true, constrained: true)
    }

    public var body: some BuilderNode {
        RequestBlock {
            RequestState[\.request.allowsCellularAccess, allowCellular]
            RequestState[\.request.allowsExpensiveNetworkAccess, allowExpensive]
            RequestState[\.request.allowsConstrainedNetworkAccess, allowConstrained]
        }
    }
}
