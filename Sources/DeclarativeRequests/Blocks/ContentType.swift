import Foundation

public struct ContentType: RequestBuildable {
    public let mimeType: MIMEType

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }

    public var body: some RequestBuildable {
        Header.contentType.setValue(mimeType.rawValue)
    }
}
