import Foundation

public struct CustomHeader: HeaderBuildable {
    public let name: String
    public let value: String
    public let mode: HeaderMode

    public init(_ name: String, _ value: String) {
        self.init(name: name, value: value, mode: .add)
    }

    init(name: String, value: String, mode: HeaderMode) {
        self.name = name
        self.value = value
        self.mode = mode
    }

    public func appending() -> CustomHeader {
        CustomHeader(name: name, value: value, mode: .add)
    }

    public func replacing() -> CustomHeader {
        CustomHeader(name: name, value: value, mode: .set)
    }

    public var body: some RequestBuildable {
        mode == .set
            ? Header.custom(name).setValue(value)
            : Header.custom(name).addValue(value)
    }
}
