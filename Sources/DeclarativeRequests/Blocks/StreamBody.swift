import Foundation

public struct StreamBody: CompositeNode {
    public init(_ url: URL) {
        stream = InputStream(url: url)
    }

    public init(_ stream: InputStream) {
        self.stream = stream
    }

    let stream: InputStream?

    public var body: some BuilderNode {
        RequestState[\.request.httpBodyStream, stream]
    }
}
