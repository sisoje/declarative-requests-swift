public struct Endpoint: RequestBuildable {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuildable {
        RequestBlock {
            $0.setPath(path)
        }
    }
}
