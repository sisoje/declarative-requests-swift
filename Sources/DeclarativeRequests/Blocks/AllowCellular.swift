public struct AllowCellular: CompositeNode {
    let allow: Bool

    public init(_ allow: Bool = true) {
        self.allow = allow
    }

    public var body: some BuilderNode {
        RequestState[\.request.allowsCellularAccess, allow]
    }
}
