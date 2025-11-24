public struct RequestTransformation: RequestBuildable {
    public init() {
        _transform = { _ in }
    }

    public init(_ transformers: RequestTransformationClosure...) {
        _transform = transformers.reduced
    }

    public init(_ transformers: [RequestTransformationClosure]...) {
        _transform = transformers.flatMap { $0 }.reduced
    }

    public init(@RequestBuilder builder: () -> any RequestBuildable) {
        _transform = builder().transform
    }

    let _transform: RequestTransformationClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}
