import Foundation

public struct CachePolicy: RequestBuildable {
    let policy: URLRequest.CachePolicy

    public init(_ policy: URLRequest.CachePolicy) {
        self.policy = policy
    }

    public var body: some RequestBuildable {
        RequestState[\.request.cachePolicy, policy]
    }
}
