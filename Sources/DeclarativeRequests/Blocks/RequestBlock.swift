public struct RequestBlock: RequestBuildable {
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    public init(@RequestBuilder builder: () -> any RequestBuildable) {
        transform = builder().transform
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}
