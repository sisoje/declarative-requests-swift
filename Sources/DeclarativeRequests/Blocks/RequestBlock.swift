public struct RequestBlock: RequestBuildable {
    public init(_ transform: @escaping RequestStateTransformClosure) {
        self.transform = transform
    }

    public init(@RequestBuilder builder: @escaping () throws -> any RequestBuildable) {
        transform = { try builder().transform($0) }
    }

    let transform: RequestStateTransformClosure

    public var body: some RequestBuildable {
        let _ = fatalError("dont call body of RequestBlock")
    }
}
