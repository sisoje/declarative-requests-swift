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
            guard let url else {
                throw DeclarativeRequestsError.badUrl
            }
            try state.setBaseURL(url)
        }
    }
}
