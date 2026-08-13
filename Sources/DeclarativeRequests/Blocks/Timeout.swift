import Foundation

public struct Timeout: RequestBuildable {
    public init(_ interval: TimeInterval) {
        self.interval = interval
    }

    let interval: TimeInterval

    public var body: some RequestBuildable {
        RequestMutation[\.timeoutInterval, interval]
    }
}
