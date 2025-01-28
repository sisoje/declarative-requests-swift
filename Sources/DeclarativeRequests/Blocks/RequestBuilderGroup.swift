struct Request: RequestBuilderNode {
    @RequestBuilder let builder: () -> RequestTransformer
    var transformer: RequestTransformer {
        builder()
    }
}
