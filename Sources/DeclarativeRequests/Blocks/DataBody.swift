import Foundation

public struct DataBody: CompositeNode {
    private enum Source {
        case data(Data)
        case file(URL)
    }

    public init(_ value: Data, mimeType: String = "application/octet-stream") {
        source = .data(value)
        self.mimeType = mimeType
    }

    public init(fileURL: URL, mimeType: String = "application/octet-stream") {
        source = .file(fileURL)
        self.mimeType = mimeType
    }

    private let source: Source

    private let mimeType: String

    public var body: some BuilderNode {
        RequestBlock { state in
            switch source {
            case let .data(value):
                state.request.httpBody = value
            case let .file(url):
                state.request.httpBodyStream = InputStream(url: url)
            }
            state.request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        }
    }
}
