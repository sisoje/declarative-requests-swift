import Foundation

public struct FileBody: CompositeNode {
    public init(_ fileURL: URL) {
        url = fileURL
    }

    private let url: URL

    public var body: some BuilderNode {
        RequestBlock { state in
            state.request.httpBodyStream = InputStream(url: url)
            assert(state.request.httpBodyStream != nil)
        }
    }
}
