import Foundation

public struct FileBody: CompositeNode {
    public init(_ url: URL) {
        self.url = url
    }

    let url: URL

    public var body: some BuilderNode {
        RequestState[\.request.httpBodyStream, InputStream(url: url)]
    }
}
