import Foundation

public struct DataBody: CompositeNode {
    private enum Source {
        case data(Data)
        case file(URL)
    }

    public init(_ value: Data) {
        source = .data(value)
    }

    public init(fileURL: URL) {
        source = .file(fileURL)
    }

    private let source: Source

    public var body: some BuilderNode {
        RequestBlock { state in
            switch source {
            case let .data(value):
                state.request.httpBody = value
            case let .file(url):
                state.request.httpBodyStream = InputStream(url: url)
            }
        }
    }
}
