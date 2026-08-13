import Foundation

public struct Cookie: RequestBuildable {
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }

    let name: String
    let value: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.cookies[name] = value
        }
    }
}
