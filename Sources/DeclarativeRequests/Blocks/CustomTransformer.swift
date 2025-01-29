public struct CustomTransformer: RequestBuilderNode {
    public init() {
        self.transformer = { _ in }
    }
    
    public init(_ transformer: RequestTransformer...) {
        self.transformer = transformer.reduced
    }
    
    public init(_ transformers: [RequestTransformer]...) {
        self.transformer = transformers.flatMap { $0 }.reduced
    }

    public let transformer: RequestTransformer
}
