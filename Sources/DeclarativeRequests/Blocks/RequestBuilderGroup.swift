struct RequestBuilderGroup: RequestBuilderNode {
    @RequestBuilder let builder: () -> RequestTransformer
    var transformer: RequestTransformer {
        builder()
    }
}
