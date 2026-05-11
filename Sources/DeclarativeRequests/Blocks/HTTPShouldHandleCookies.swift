import Foundation

public struct HTTPShouldHandleCookies: RequestBuildable {
    let value: Bool

    public init(_ value: Bool) {
        self.value = value
    }

    public var body: some RequestBuildable {
        RequestState[\.request.httpShouldHandleCookies, value]
    }
}
