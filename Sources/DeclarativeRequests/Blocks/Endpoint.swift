import Foundation

public struct Endpoint: RequestBuildable {
    public init(_ path: String) {
        self.path = path
    }

    let path: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            let current = state.request.url ?? .placeholder
            guard let resolved = URL(string: path, relativeTo: current)?.absoluteURL else {
                throw DeclarativeRequestsError.badUrl
            }
            state.request.url = resolved.preservingQuery(from: current)
        }
    }
}

private extension URL {
    func preservingQuery(from other: URL) -> URL {
        guard
            var c = URLComponents(url: self, resolvingAgainstBaseURL: true),
            c.percentEncodedQuery == nil,
            let q = URLComponents(url: other, resolvingAgainstBaseURL: true)?.percentEncodedQuery
        else {
            return self
        }
        c.percentEncodedQuery = q
        return c.url ?? self
    }
}
