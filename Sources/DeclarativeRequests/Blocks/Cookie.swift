import Foundation

public struct Cookie: RequestBuildable {
    private let items: [String: String]

    public init(_ name: String, _ value: String) {
        self.init([name: value])
    }

    public init(_ cookies: [String: String]) {
        items = cookies
    }

    public var body: some RequestBuildable {
        RequestTransformation { state in
            for (name, value) in items {
                state.cookies[name] = value
            }

            let cookieString = state.cookies
                .map { "\($0.key)=\($0.value)" }
                .sorted()
                .joined(separator: "; ")

            if !cookieString.isEmpty {
                state.request.setValue(cookieString, forHTTPHeaderField: Header.cookie.rawValue)
            }
        }
    }
}
