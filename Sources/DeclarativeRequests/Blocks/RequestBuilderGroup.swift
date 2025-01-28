public struct RequestGroup: RequestBuilderNode {
    public init(@RequestBuilder builder: () -> RequestTransformer) {
        transformer = builder()
    }

    let transformer: RequestTransformer
}
