import Foundation

/// Applies only after the path and query are finished — the base combines with exactly those two axes. Header/body blocks may follow freely.
public struct BaseURL: RequestBuildable {
    enum Source {
        case url(URL)
        case urlString(String)
    }

    public init(_ url: URL) {
        source = .url(url)
    }

    public init(_ string: String) {
        source = .urlString(string)
    }

    let source: Source

    public var body: some RequestBuildable {
        RequestBlock { state in
            switch source {
            case let .url(url):
                state.setBaseURL(url)
            case let .urlString(string):
                if let url = URL(string: string) {
                    state.setBaseURL(url)
                }
            }
        }
    }
}
