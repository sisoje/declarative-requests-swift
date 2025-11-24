public struct RequestTransformation: RequestBuildable {
    public init() {
        transform = { _ in }
    }

    public init(_ transformers: RequestTransformationClosure...) {
        transform = transformers.reduced
    }

    public init(_ transformers: [RequestTransformationClosure]...) {
        transform = transformers.flatMap { $0 }.reduced
    }

    public init(@RequestBuilder builder: () -> RequestBuildable) {
        transform = builder().transformRequest
    }

    public let transform: RequestTransformationClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of StateTransformationNode")
    }
}
