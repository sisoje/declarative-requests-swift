import Foundation

public struct Cookie: RequestBuildable {
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }

    let key: String
    let value: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.cookies[key] = value
        }
    }
}
