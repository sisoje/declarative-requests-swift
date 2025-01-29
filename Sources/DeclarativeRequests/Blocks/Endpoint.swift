public struct Endpoint: RequestBuilderModifyNode {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    var body: some RequestBuilderNode {
        RequestBuilderState[\.pathComponents.path, path]
    }
}
