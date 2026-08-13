import Foundation

public struct Accept: RequestBuildable {
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
