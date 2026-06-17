import Foundation

public struct Timeout: RequestBuildable {
    let interval: TimeInterval

    public init(_ interval: TimeInterval) {
        self.interval = interval
    }

    public var body: some RequestBuildable {
        RequestMutation[\.timeoutInterval, interval]
    }
}
