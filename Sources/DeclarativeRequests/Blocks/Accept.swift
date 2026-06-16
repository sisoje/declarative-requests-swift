import Foundation

public struct Accept: RequestBuildable, Sendable {
    let mimeType: MIMEType

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.header(Header.accept.rawValue).addValue(mimeType.rawValue)
        }
    }
}
