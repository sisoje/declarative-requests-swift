import Foundation

public struct CustomHeader: HeaderBuildable {
    public let name: String
    public let value: String

    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }

    public var body: some RequestBuildable {
        RequestBlock { state in
            let shouldAdd = state.shouldAddHeaders ?? true
            if shouldAdd {
                state.request.addValue(value, forHTTPHeaderField: name)
            } else {
                state.request.setValue(value, forHTTPHeaderField: name)
            }
        }
    }
}
