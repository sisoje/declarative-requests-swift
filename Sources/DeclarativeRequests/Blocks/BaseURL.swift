import Foundation

public struct BaseURL: RequestBuildable {
    public init(_ url: URL) {
        self.urlString = url.absoluteString
    }

    public init(_ string: String) {
        urlString = string
    }

    let urlString: String

    public var body: some RequestBuildable {
        RequestBlock { state in
            guard let url = URL(string: urlString) else {
                throw DeclarativeRequestsError.badUrl
            }
            state.baseURL = url
        }
    }
}
