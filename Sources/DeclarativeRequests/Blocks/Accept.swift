import Foundation

public struct Accept: RequestBuildable, Sendable {
    let mimeType: MIMEType

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            let field = Header.accept.rawValue
            if let existing = state.request.value(forHTTPHeaderField: field) {
                state.request.setValue("\(existing), \(mimeType.rawValue)", forHTTPHeaderField: field)
            } else {
                state.request.setValue(mimeType.rawValue, forHTTPHeaderField: field)
            }
        }
    }
}
