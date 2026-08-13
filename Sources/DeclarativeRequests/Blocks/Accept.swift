import Foundation

public struct Accept: RequestBuildable {
    let value: String

    public init(_ value: String) {
        self.value = value
    }

    public var body: some RequestBuildable {
        RequestStateTransformer { state in
            state.request.addValue(value, forHTTPHeaderField: Header.accept.rawValue)
        }
    }
}
