import Foundation

public struct NetworkServiceType: RequestBuildable {
    let type: URLRequest.NetworkServiceType

    public init(_ type: URLRequest.NetworkServiceType) {
        self.type = type
    }

    public var body: some RequestBuildable {
        RequestState[\.request.networkServiceType, type]
    }
}
