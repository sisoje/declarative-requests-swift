public struct RequestBlock: RequestBuildable {
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    public init(@RequestBuilder builder: () throws -> any RequestBuildable) rethrows {
        transform = try builder().transform
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of RequestBlock")
    }
}
