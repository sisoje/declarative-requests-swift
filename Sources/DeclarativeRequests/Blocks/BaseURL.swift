import Foundation

public struct BaseURL: RequestBuilderNode {
    public init(_ url: URL?) {
        self.url = url
    }

    public init(_ string: String) {
        url = URL(string: string)
    }

    let url: URL?
    public var body: some RequestBuilderRootNode {
        RequestBuilderState[\RequestBuilderState.baseURL, url]
    }
}
