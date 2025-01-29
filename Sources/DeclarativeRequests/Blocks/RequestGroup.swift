public struct RequestGroup: RequestBuilderNode {
    public init(@RequestBuilder builder: () -> RequestBuilderNode) {
        transformer = builder().transformer
    }

    public let transformer: RequestTransformer
}
