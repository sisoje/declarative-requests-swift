import Foundation

public struct BaseURL: CompositeNode {
    public init(_ url: URL?) {
        self.url = url
    }

    public init(_ string: String) {
        url = URL(string: string)
    }

    
    let url: URL?
    public var body: some BuilderNode {
        RequestState[\RequestState.baseURL, url]
    }
    // probam sranje
}
