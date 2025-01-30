import Foundation

public struct DataBody: CompositeNode {
    private enum Source {
        case data(Data)
        case file(URL)
    }

    public init(_ value: Data, mimeType: String = "application/octet-stream") {
        self.source = .data(value)
        self.mimeType = mimeType
    }

    public init(fileURL: URL, mimeType: String = "application/octet-stream") {
        self.source = .file(fileURL)
        self.mimeType = mimeType
    }

    private let source: Source
    
    private let mimeType: String

    public var body: some BuilderNode {
        RootNode { state in
            switch source {
            case .data(let value):
                state.request.httpBody = value
            case .file(let url):
                state.request.httpBodyStream = InputStream(url: url)
            }
            state.request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        }
    }
}
