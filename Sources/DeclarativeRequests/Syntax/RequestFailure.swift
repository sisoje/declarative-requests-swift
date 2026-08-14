/// A block that fails the build with the given error.
public struct RequestFailure: RequestBuildable {
    public init(_ error: some Error) {
        self.error = error
    }

    let error: any Error

    public var body: some RequestBuildable {
        RequestBlock { _ in throw error }
    }
}
