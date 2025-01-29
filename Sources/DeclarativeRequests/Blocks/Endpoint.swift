public struct Endpoint: CompositeNode {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some BuilderNode {
        RequestState[\.pathComponents.path, path]
    }
}
