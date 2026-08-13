import Foundation

public struct ContentType: RequestBuildable {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public var body: some RequestBuildable {
        Header.contentType.setValue(value)
    }
}
