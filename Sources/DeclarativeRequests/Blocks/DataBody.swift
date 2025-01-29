import Foundation

public struct DataBody: CompositeNode {
    private enum Source {
        case data(Data)
        case file(URL)
    }

    public init(_ value: Data) {
        self.source = .data(value)
    }

    public init(fileURL: URL) {
        self.source = .file(fileURL)
    }

    private let source: Source

    public var body: some BuilderNode {
        RootNode { state in
            switch source {
            case .data(let value):
                state.request.httpBody = value
            case .file(let url):
                state.request.httpBodyStream = InputStream(url: url)
            }
            state.request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        }
    }
}
