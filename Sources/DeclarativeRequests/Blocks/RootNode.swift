public struct RootNode: RequestBuilderRootNode {
    public init() {
        self.transformer = { _ in }
    }
    
    public init(_ transformer: StateTransformer...) {
        self.transformer = transformer.reduced
    }
    
    public init(_ transformers: [StateTransformer]...) {
        self.transformer = transformers.flatMap { $0 }.reduced
    }
    
    public init(@RequestBuilder builder: () -> RequestBuilderRootNode) {
        transformer = builder().transformer
    }

    public let transformer: StateTransformer
}
