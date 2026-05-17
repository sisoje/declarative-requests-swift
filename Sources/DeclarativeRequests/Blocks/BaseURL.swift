import Foundation

public struct BaseURL: RequestBuildable {
    public init(_ url: URL?) {
        self.url = url
    }

    public init(_ string: String) {
        url = URL(string: string)
    }

    let url: URL?

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard
                let url,
                let base = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else {
                throw DeclarativeRequestsError.badUrl
            }
            var c = state.request.url
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }
                ?? URLComponents()
            c.scheme = base.scheme
            c.user = base.user
            c.password = base.password
            c.host = base.host
            c.port = base.port
            if c.path.isEmpty || c.path == "/" {
                c.path = base.path
            } else if !c.path.hasPrefix("/") {
                c.path = "/" + c.path
            }
            state.request.url = c.url
        }
    }
}
