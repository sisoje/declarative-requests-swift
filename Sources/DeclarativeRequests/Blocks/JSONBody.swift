import Foundation

public struct JSONBody: RequestBuildable {
    public init(_ value: any Encodable) {
        self.value = value
    }

    let value: any Encodable

    public var body: some RequestBuildable {
        RequestBlock { state in
            state.request.httpBody = try state.encoder.encode(value)
        }
        ContentType.JSON
    }
}
