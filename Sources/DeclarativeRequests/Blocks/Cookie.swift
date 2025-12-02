import Foundation

public struct Cookie: RequestBuildable {
    private let cookies: [String: String]

    public init(_ name: String, _ value: String) {
        cookies = [name: value]
    }

    public init(_ dict: [String: String]) {
        cookies = dict
    }

    public var body: some RequestBuildable {
        RequestTransformation { state in
            state.cookies.merge(cookies, uniquingKeysWith: { _, new in new })
        }
    }
}
