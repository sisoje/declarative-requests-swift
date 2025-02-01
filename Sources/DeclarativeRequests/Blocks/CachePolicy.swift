import Foundation

public struct CachePolicy: CompositeNode {
    let policy: URLRequest.CachePolicy

    public init(_ policy: URLRequest.CachePolicy) {
        self.policy = policy
    }

    public var body: some BuilderNode {
        RequestState[\.request.cachePolicy, policy]
    }
}
