import Foundation

public struct ContentType: RequestBuildable, Sendable {
    public let mimeType: MIMEType

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }

    public var body: some RequestBuildable {
        Header.contentType.setValue(mimeType.rawValue)
    }
}
