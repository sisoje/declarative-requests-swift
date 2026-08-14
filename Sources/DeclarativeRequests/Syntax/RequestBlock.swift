public struct RequestBlock: RequestBuildable {
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    public init(@RequestBuilder builder: () -> any RequestBuildable) {
        transform = builder().transform
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        // Not fatalError: a never-returning body puts a "will never be executed" warning in every
        // consumer's build. `transform` short-circuits the leaf, so this never runs.
        assertionFailure("dont call body of RequestBlock")
        return self
    }
}
