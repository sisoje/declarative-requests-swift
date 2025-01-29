public struct RootNode: RequestBuilderNode {
    public init() {
        transformer = { _ in }
    }

    public init(_ transformers: StateTransformer...) {
        transformer = transformers.reduced
    }

    public init(_ transformers: [StateTransformer]...) {
        transformer = transformers.flatMap { $0 }.reduced
    }

    public init(@RequestBuilder builder: () -> RequestBuilderNode) {
        transformer = builder().transformer
    }

    public let transformer: StateTransformer
}
