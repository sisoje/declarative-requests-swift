/// Sets the path, replacing any previous one. Interpolated values are not escaped — percent-encode dynamic segments yourself.
public struct Endpoint: RequestBuildable {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuildable {
        RequestBlock {
            $0.path = path
        }
    }
}
