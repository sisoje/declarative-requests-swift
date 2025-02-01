import Foundation

public struct Timeout: CompositeNode {
    let interval: TimeInterval

    public init(_ interval: TimeInterval) {
        self.interval = interval
    }

    public var body: some BuilderNode {
        RequestState[\.request.timeoutInterval, interval]
    }
}
