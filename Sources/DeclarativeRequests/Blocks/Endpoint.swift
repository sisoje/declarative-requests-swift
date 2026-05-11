public struct Endpoint: RequestBuildable {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuildable {
        RequestBlock {
            try $0.setPath(path)
        }
    }
}
