public struct Endpoint: RequestBuilderNode {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuilderRootNode {
        RequestBuilderState[\.pathComponents.path, path]
    }
}
