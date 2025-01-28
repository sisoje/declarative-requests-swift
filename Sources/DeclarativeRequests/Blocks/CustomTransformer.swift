public struct CustomTransformer: RequestBuilderNode {
    public init(transformer: @escaping RequestTransformer) {
        self.transformer = transformer
    }

    let transformer: RequestTransformer
}
