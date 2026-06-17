public struct RequestStateTransformer: RequestBuildable {
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}


