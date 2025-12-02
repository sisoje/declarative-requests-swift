public struct RequestBlock: RequestBuildable {
    public init(_ transform: @escaping RequestTransformationClosure = { _ in }) {
        _transform = transform
    }

    public init(@RequestBuilder builder: () -> any RequestBuildable) {
        _transform = builder().transform
    }

    let _transform: RequestTransformationClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}
