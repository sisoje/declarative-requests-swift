import Foundation

public struct Accept: RequestBuildable, Sendable {
    let mimeType: MIMEType

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }

    public var body: some RequestBuildable {
        RequestStateTransformer { state in
            state.request.addValue(mimeType.rawValue, forHTTPHeaderField: Header.accept.rawValue)
        }
    }
}
