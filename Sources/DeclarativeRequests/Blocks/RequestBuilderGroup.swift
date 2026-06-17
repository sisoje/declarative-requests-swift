public struct RequestBuilderGroup: RequestBuildable {
    let builder: () -> any RequestBuildable
    
    public init(@RequestBuilder builder: @escaping () -> any RequestBuildable) {
        self.builder = builder
    }

    public var body: some RequestBuildable {
        builder()
    }
}
